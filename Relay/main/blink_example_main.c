#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_log.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "nvs_flash.h"
#include "esp_netif.h"
#include "driver/gpio.h"
#include "led_strip.h"

// ⚡ HTTP & MQTT
#include "esp_http_client.h"
#include "mqtt_client.h"
#include "esp_crt_bundle.h"

// ⚡ WIFI PROVISIONING (Chính chủ ESP BLEProv)
#include "wifi_provisioning/manager.h"
#include "wifi_provisioning/scheme_ble.h"
#include "esp_coexist.h"  // Coexistence WiFi/BLE

// Hardware Defines
#define RELAY_GPIO        GPIO_NUM_2
#define BUTTON_GPIO       GPIO_NUM_10
#define USE_RGB_LED       false

// Device Info
#define DEVICE_HARDWARE_ID "thiet_bi_esp32_relay"
#define PROV_DEVICE_NAME   "PROV_" DEVICE_HARDWARE_ID
#define PROV_SECURITY_VER  WIFI_PROV_SECURITY_1
#define PROV_POP           "esp123456"  // 🔑 Mật khẩu (Proof of Possession) khi quét QR

// MQTT Config (HiveMQ)
#define MQTT_BROKER_URL   "mqtts://cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud:8883"
#define MQTT_USERNAME     "smarthome"
#define MQTT_PASSWORD     "Smarthome123"
#define MQTT_TOPIC_SUB    "smarthome/devices/" DEVICE_HARDWARE_ID "/set"
#define MQTT_TOPIC_PUB    "smarthome/devices/" DEVICE_HARDWARE_ID "/state"

static const char *TAG = "SMART_PLUG";
static bool s_relay_state = false;
static esp_mqtt_client_handle_t s_mqtt_client = NULL;

// Forward Declarations
static void mqtt_app_start(void);
static void sync_state_to_mqtt(void);
void button_task(void *pvParameters);
void set_led_color(uint8_t r, uint8_t g, uint8_t b); // Khai báo trước

// ... (code khác)




/* =====================================================
 *                  EVENT HANDLERS
 * ===================================================== */

// Sự kiện WiFi & IP
static void event_handler(void* arg, esp_event_base_t event_base,
                          int32_t event_id, void* event_data) {
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } 
    else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        ESP_LOGW(TAG, "⚠️ WiFi Disconnected. Retrying...");
        // esp_wifi_connect();  // <--- TẮT ĐỂ MANAGER TỰ LO
    }  
    else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "🌐 Connected! IP: " IPSTR, IP2STR(&event->ip_info.ip));
        
        // Có IP rồi mới kết nối MQTT
        mqtt_app_start();
    }
}

// Task "Sát thủ" để tắt Provisioning an toàn sau 4 giây
void stop_prov_task(void *param) {
    vTaskDelay(pdMS_TO_TICKS(8000)); // Tăng lên 4s để WiFi có nhiều thời gian Auth
    ESP_LOGW(TAG, "🛑 STOPPING BLE PROVISIONING NOW (SAFE MODE)...");
    wifi_prov_mgr_stop_provisioning();
    
    // Force WiFi reconnect ngay sau khi BLE stop
    vTaskDelay(pdMS_TO_TICKS(500));
    ESP_LOGW(TAG, "⚡ FORCING WIFI CONNECTION...");
    esp_wifi_connect();
    
    vTaskDelete(NULL);
}

// Xử lý sự kiện nhận được Pass WiFi
static void sys_prov_event_handler(void* arg, esp_event_base_t event_base,
                                   int32_t event_id, void* event_data) {
    if (event_base == WIFI_PROV_EVENT && event_id == WIFI_PROV_CRED_RECV) {
        ESP_LOGW(TAG, "📩 RECEIVED WIFI CREDENTIALS -> SCHEDULING BLE STOP IN 2s...");
        // Tạo task riêng để stop, tránh bị treo (WDT)
        xTaskCreate(stop_prov_task, "stop_prov", 2048, NULL, 5, NULL);
    }
}

static void wifi_init_sta(void) {
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    // ⚡ QUAN TRỌNG: Tắt Power Save Mode để WiFi khỏe nhất
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_ps(WIFI_PS_NONE));
    
    // ⚡ ƯU TIÊN WIFI HƠN BLE (Fix xung đột Coexistence)
    ESP_ERROR_CHECK(esp_coex_preference_set(ESP_COEX_PREFER_WIFI));
    
    // Đăng ký Event Handler cơ bản
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_PROV_EVENT, WIFI_PROV_CRED_RECV, &sys_prov_event_handler, NULL));
}



// Hàm Provisioning lấy QR
static void get_device_service_name(char *service_name, size_t max) {
    uint8_t eth_mac[6];
    const char *ssid_prefix = "PROV_";
    esp_wifi_get_mac(WIFI_IF_STA, eth_mac);
    snprintf(service_name, max, "%s%02X%02X%02X",
             ssid_prefix, eth_mac[3], eth_mac[4], eth_mac[5]);
}

/* =====================================================
 *                  MAIN LOGIC
 * ===================================================== */
void app_main(void) {
    // ⚡ FORCE RESET: Đã tắt reset để giữ kết nối ổn định
    // ESP_LOGW(TAG, "🧹 FACTORY RESET: Erasing NVS to force provisioning mode...");
    // nvs_flash_erase();
    
    // 1. Init NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    // 2. Setup GPIO
    gpio_reset_pin(RELAY_GPIO);
    gpio_set_direction(RELAY_GPIO, GPIO_MODE_OUTPUT);
    gpio_set_level(RELAY_GPIO, 0); 
    
    // 3. Init WiFi & Provisioning Manager
    wifi_init_sta();
    
    wifi_prov_mgr_config_t config = {
        .scheme = wifi_prov_scheme_ble, // Dùng BLE (Quan trọng cho App ESP BLEProv)
        .scheme_event_handler = WIFI_PROV_SCHEME_BLE_EVENT_HANDLER_FREE_BTDM
    };
    ESP_ERROR_CHECK(wifi_prov_mgr_init(config));

    bool provisioned = false;
    ESP_ERROR_CHECK(wifi_prov_mgr_is_provisioned(&provisioned));

    if (!provisioned) {
        ESP_LOGI(TAG, "🚀 STARTING BLE PROVISIONING...");
        
        char service_name[12];
        get_device_service_name(service_name, sizeof(service_name));
        
        // Endpoint cấu hình
        wifi_prov_security_t security = PROV_SECURITY_VER;
        const char *pop = PROV_POP; 
        wifi_prov_security1_params_t *sec_params = pop;
        // const char *username = NULL;

        // BẮT ĐẦU PROVISIONING
        // Chú ý: Dùng QR Code
        ESP_ERROR_CHECK(wifi_prov_mgr_start_provisioning(security, (const void *)sec_params, service_name, NULL));

        // ⚡ AUTO-STOP BLE KHI NHẬN ĐƯỢC CONFIG (Fix lỗi Coexistence)
        // Chúng ta sẽ đợi sự kiện nhận Pass xong là kill BLE luôn


        // 🖨️ IN MÃ QR RA MÀN HÌNH
        ESP_LOGI(TAG, "=================================================");
        ESP_LOGI(TAG, "📱 Scan QR code below with 'ESP BLEProv' App:");
        ESP_LOGI(TAG, "=================================================");
        // wifi_prov_print_qr không có trong ESP-IDF 5.1.6
        // Tạo QR URL thay thế:
        char qr_payload[256];
        snprintf(qr_payload, sizeof(qr_payload), 
                 "{\"ver\":\"v1\",\"name\":\"%s\",\"pop\":\"%s\",\"transport\":\"ble\"}", 
                 service_name, pop);
        ESP_LOGI(TAG, "🔗 Open this URL to get QR code:");
        ESP_LOGI(TAG, "https://chart.googleapis.com/chart?chs=400x400&cht=qr&chl=%s", qr_payload);
        ESP_LOGI(TAG, "=================================================");
        ESP_LOGI(TAG, "� Or connect manually:");
        ESP_LOGI(TAG, "🔑 Device Name: %s | POP: %s", service_name, pop);
        ESP_LOGI(TAG, "=================================================");
        
    } else {
        ESP_LOGI(TAG, "✅ Device already provisioned. Connecting to WiFi...");
        wifi_prov_mgr_deinit();
        esp_wifi_start(); // Start WiFi để auto-connect
    }

    // 4. Start Button Task
    xTaskCreate(button_task, "button_task", 4096, NULL, 10, NULL);
}

/* =====================================================
 *                  MQTT & LOGIC
 * ===================================================== */
static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data) {
    esp_mqtt_event_handle_t event = event_data;
    switch ((esp_mqtt_event_id_t)event_id) {
    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "MQTT Connected");
        s_mqtt_client = event->client;
        esp_mqtt_client_subscribe(event->client, MQTT_TOPIC_SUB, 1);
        sync_state_to_mqtt();
        break;
    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGI(TAG, "MQTT Disconnected");
        break;
    case MQTT_EVENT_DATA:
        char msg[10];
        if (event->data_len < sizeof(msg)) {
            memcpy(msg, event->data, event->data_len);
            msg[event->data_len] = 0;
            if (strcmp(msg, "ON") == 0) {
                s_relay_state = true;
                gpio_set_level(RELAY_GPIO, 1);
                sync_state_to_mqtt();
            } else if (strcmp(msg, "OFF") == 0) {
                s_relay_state = false;
                gpio_set_level(RELAY_GPIO, 0);
                sync_state_to_mqtt();
            } else if (strstr(msg, "RESET")) {
                 // Reset WiFi nếu App gửi lệnh
                 nvs_flash_erase();
                 esp_restart();
            }
        }
        break;
    default: break;
    }
}

static void sync_state_to_mqtt(void) {
    // ⚡ LOG GUARANTEED: Dùng printf và LOGE để chắc chắn hiện
    const char* state_str = s_relay_state ? "ON" : "OFF";
    printf("\n======================================\n");
    printf("💡 RELAY CHANGED TO: %s\n", state_str);
    printf("======================================\n");
    ESP_LOGE(TAG, "👉 STATUS UPDATE: Relay is %s", state_str);

    if (s_mqtt_client) {
        // Gửi trạng thái mới nhất lên App
        // ⚡ Tối ưu: Dùng QoS 0 để đẩy trạng thái đi cực nhanh, giảm trễ mạng
        esp_mqtt_client_publish(s_mqtt_client, MQTT_TOPIC_PUB, state_str, 0, 0, 1);
        
        // Cập nhật LED báo hiệu (Xanh dương = ON, Tắt = OFF)
        if (s_relay_state) set_led_color(0, 0, 50); // Xanh dương nhẹ
        else set_led_color(0, 0, 0); // Tắt
        
        ESP_LOGI(TAG, "Relay event published: %s (QoS 0)", state_str);
    }
}

static void mqtt_app_start(void) {
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = MQTT_BROKER_URL,
        .credentials.username = MQTT_USERNAME,
        .credentials.authentication.password = MQTT_PASSWORD,
        .broker.verification.crt_bundle_attach = esp_crt_bundle_attach,
    };
    s_mqtt_client = esp_mqtt_client_init(&mqtt_cfg);
    esp_mqtt_client_register_event(s_mqtt_client, ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    esp_mqtt_client_start(s_mqtt_client);
}



void button_task(void *pvParameters) {
    // 🔘 Nút điều khiển Relay (GPIO 10)
    gpio_set_direction(BUTTON_GPIO, GPIO_MODE_INPUT);
    gpio_set_pull_mode(BUTTON_GPIO, GPIO_PULLUP_ONLY);

    // 🔘 Nút BOOT để Reset (GPIO 9 - Có sẵn trên C3 SuperMini)
    #define BOOT_BUTTON_GPIO GPIO_NUM_9
    gpio_set_direction(BOOT_BUTTON_GPIO, GPIO_MODE_INPUT);
    gpio_set_pull_mode(BOOT_BUTTON_GPIO, GPIO_PULLUP_ONLY);

    int last_relay_btn_state = gpio_get_level(BUTTON_GPIO);
    int boot_btn_timer = 0;

    while (1) {
        // --- XỬ LÝ CÔNG TẮC BẬP BÊNH (TOGGLE SWITCH) GPIO 10 ---
        // Công tắc bập bênh: Gạt xuống (0) = ON, Gạt lên (1) = OFF
        int current_switch_state = gpio_get_level(BUTTON_GPIO);
        if (current_switch_state != last_relay_btn_state) {
            vTaskDelay(pdMS_TO_TICKS(50)); // Chống rung
            if (gpio_get_level(BUTTON_GPIO) == current_switch_state) {
                // Đồng bộ Relay theo trạng thái Switch
                // Switch = 0 (gạt xuống) -> Relay ON
                // Switch = 1 (gạt lên)   -> Relay OFF
                s_relay_state = (current_switch_state == 0) ? 1 : 0;
                gpio_set_level(RELAY_GPIO, s_relay_state);
                sync_state_to_mqtt();
                ESP_LOGI(TAG, "🔄 Switch Changed -> Relay: %s", s_relay_state ? "ON" : "OFF");
                last_relay_btn_state = current_switch_state;
            }
        }

        // --- XỬ LÝ NÚT BOOT (RESET WIFI) ---
        if (gpio_get_level(BOOT_BUTTON_GPIO) == 0) { // Đang nhấn giữ
            boot_btn_timer += 50; // Cộng dồn thời gian (mỗi loop 50ms)
            if (boot_btn_timer >= 3000) { // Giữ > 3 giây
                ESP_LOGE(TAG, "🧹 BOOT BUTTON HELD 3S -> FACTORY RESET & RESTART!");
                
                // Nháy đèn đỏ cảnh báo
                for(int i=0; i<5; i++) {
                    set_led_color(255, 0, 0); vTaskDelay(100);
                    set_led_color(0, 0, 0);   vTaskDelay(100);
                }

                nvs_flash_erase(); // Xóa sạch NVS
                esp_restart();     // Khởi động lại
            }
        } else {
            boot_btn_timer = 0; // Nhả nút thì reset đếm
        }

        vTaskDelay(pdMS_TO_TICKS(50));
    }
}

// =====================================================
//                  LED CONTROL
// =====================================================
static led_strip_handle_t led_strip;

static void configure_led(void)
{
    /* LED strip initialization with the GPIO and pixels number */
    led_strip_config_t strip_config = {
        .strip_gpio_num = 8, // GPIO 8 cho ESP32-C3 SuperMini (Onboard LED)
        .max_leds = 1, 
    };
    led_strip_rmt_config_t rmt_config = {
        .resolution_hz = 10 * 1000 * 1000, // 10MHz
        .flags.with_dma = false,
    };
    ESP_ERROR_CHECK(led_strip_new_rmt_device(&strip_config, &rmt_config, &led_strip));
    led_strip_clear(led_strip);
}

void set_led_color(uint8_t r, uint8_t g, uint8_t b) {
    if (led_strip == NULL) {
        configure_led();
    }
    led_strip_set_pixel(led_strip, 0, r, g, b);
    led_strip_refresh(led_strip);
}
