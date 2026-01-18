#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"

#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_system.h"
#include "nvs_flash.h"
#include "esp_netif.h"

#include "esp_http_server.h"
#include "cJSON.h"
#include "mqtt_client.h"
#include "esp_crt_bundle.h"
#include "driver/gpio.h"
#include "led_strip.h"

#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"

/* =====================================================
 *                  PIN DEFINITIONS (ESP32-C3)
 * ===================================================== */
#define RELAY_GPIO        GPIO_NUM_2  // ⚠️ ĐỔI TỪ GPIO 8 → GPIO 2 (GPIO 8 không hoạt động)
#define BUTTON_GPIO       GPIO_NUM_10  
#define ACS_CHANNEL       ADC_CHANNEL_0 

// #define RGB_GPIO          GPIO_NUM_8 
#define USE_RGB_LED       false       

#define HARDWARE_ID       "thiet_bi_esp32"
#define BLE_DEVICE_NAME   "PROV_" HARDWARE_ID

#define MQTT_TOPIC_SUB     "smarthome/devices/" HARDWARE_ID "/set"
#define MQTT_TOPIC_PUB     "smarthome/devices/" HARDWARE_ID "/state"
#define MQTT_TOPIC_SENSOR  "smarthome/devices/" HARDWARE_ID "/sensor"

/* =====================================================
 *                  BLE PROVISIONING (NimBLE)
 * ===================================================== */
#include "nimble/nimble_port.h"
#include "nimble/nimble_port_freertos.h"
#include "host/ble_hs.h"
#include "host/util/util.h"
#include "services/gap/ble_svc_gap.h"
#include "services/gatt/ble_svc_gatt.h"

static uint16_t wifi_config_handle;
static uint8_t ble_addr_type;
static bool ble_is_connected = false;
static uint8_t ble_char_value[256] = {0};

/* =====================================================
 *                  CONSTANTS & GLOBALS
 * ===================================================== */
static const char *TAG = "SMART_PLUG";

static bool s_relay_state = false;
static esp_mqtt_client_handle_t s_mqtt_client = NULL;
static led_strip_handle_t led_strip;

/* =====================================================
 *                  HELPER FUNCTIONS
 * ===================================================== */

// Forward declaration
static esp_err_t save_wifi_credentials(const char *ssid, const char *password);

static void configure_led(void) {
    #if USE_RGB_LED
        led_strip_config_t strip_config = {
            .strip_gpio_num = RGB_GPIO,
            .max_leds = 1,
        };
        led_strip_rmt_config_t rmt_config = {
            .resolution_hz = 10 * 1000 * 1000, // 10MHz
        };
        ESP_ERROR_CHECK(led_strip_new_rmt_device(&strip_config, &rmt_config, &led_strip));
        led_strip_clear(led_strip);
    #endif
}

static void set_led_color(uint8_t r, uint8_t g, uint8_t b) {
    #if USE_RGB_LED
        if (led_strip) {
            led_strip_set_pixel(led_strip, 0, r, g, b);
            led_strip_refresh(led_strip);
        }
    #endif
}

static void sync_state_to_mqtt() {
    if (s_mqtt_client) {
        // Gửi trạng thái mới nhất lên App
        const char* msg = s_relay_state ? "ON" : "OFF";
        // ⚡ Tối ưu: Dùng QoS 0 để đẩy trạng thái đi cực nhanh, giảm trễ mạng
        esp_mqtt_client_publish(s_mqtt_client, MQTT_TOPIC_PUB, msg, 0, 0, 1);
        
        // Cập nhật LED báo hiệu (Xanh dương = ON, Tắt = OFF)
        if (s_relay_state) set_led_color(0, 0, 50); // Xanh dương nhẹ
        else set_led_color(0, 0, 0); // Tắt
        
        ESP_LOGI(TAG, "Relay event published: %s (QoS 0)", msg);
    }
}

/* =====================================================
 *                  BUTTON TASK (ULTRA DEBOUNCE)
 * ===================================================== */

void button_task(void *pvParameters)
{
    gpio_set_direction(BUTTON_GPIO, GPIO_MODE_INPUT);
    gpio_set_pull_mode(BUTTON_GPIO, GPIO_PULLUP_ONLY);

    vTaskDelay(pdMS_TO_TICKS(100));
    int last_state = gpio_get_level(BUTTON_GPIO);
    
    // Các biến cho tính năng Reset bằng cách gạt nhanh 5 lần
    uint32_t last_toggle_tick = 0;
    int toggle_count = 0;

    ESP_LOGI(TAG, "💡 Toggle Switch mode started on GPIO %d", BUTTON_GPIO);
    
    while (1) {
        int current_state = gpio_get_level(BUTTON_GPIO);

        // Phát hiện bất kỳ sự thay đổi trạng thái nào (Gạt lên hoặc Gạt xuống)
        if (current_state != last_state) {
            vTaskDelay(pdMS_TO_TICKS(50)); // Chống rung
            if (gpio_get_level(BUTTON_GPIO) == current_state) {
                // 1. Đảo trạng thái Relay ngay lập tức
                s_relay_state = !s_relay_state;
                gpio_set_level(RELAY_GPIO, s_relay_state);
                sync_state_to_mqtt();
                ESP_LOGI(TAG, "🔄 Wall Switch Toggled: %s", s_relay_state ? "ON" : "OFF");
                
                last_state = current_state;
            }
        }
        vTaskDelay(pdMS_TO_TICKS(20)); // ⚡ Tăng độ nhạy: Quét 20ms thay vì 50ms
    }
}

/* =====================================================
 *                  TEST MODE CONFIG (QUAN TRỌNG)
 *  Điền WiFi nhà bạn vào đây để test MQTT không cần App
 * ===================================================== */
#define TEST_WIFI_SSID    "p"     // <--- Sửa tên WiFi ở đây
#define TEST_WIFI_PASS    "12345678"        // <--- Sửa mật khẩu ở đây
#define FORCE_TEST_MODE   false                  // Đổi thành false nếu muốn quay lại dùng App cài đặt

/* =====================================================
 *                  FUNCTION PROTOTYPES
 * ===================================================== */
static void mqtt_app_start(void); 

/* =====================================================
 *                  MQTT CONFIGURATION (HIVEMQ CLOUD)
 * ===================================================== */
#define MQTT_BROKER_URL   "mqtts://cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud:8883"
#define MQTT_USERNAME     "smarthome"
#define MQTT_PASSWORD     "Smarthome123"
#define MQTT_CLIENT_ID    "ESP32_SmartPlug_001"

/* =====================================================
 *                  HARDWARE CONFIG
 * ===================================================== */

/* =====================================================
 *                  MQTT HANDLER
 * ===================================================== */
static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data) {
    esp_mqtt_event_handle_t event = event_data;
    
    switch ((esp_mqtt_event_id_t)event_id) {
    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "MQTT Connected");
        s_mqtt_client = event->client;
        // Subscribe wildcard để nhận lệnh cho bất kỳ ID nào (dùng cho test)
        esp_mqtt_client_subscribe(event->client, "smarthome/devices/+/set", 1);
        set_led_color(0, 50, 0); // Xanh lá: Đã kết nối
        vTaskDelay(pdMS_TO_TICKS(500));
        sync_state_to_mqtt(); // Đồng bộ trạng thái ban đầu
        break;
        
    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGI(TAG, "MQTT Disconnected");
        set_led_color(50, 0, 0); // Đỏ: Mất kết nối
        break;
        
    case MQTT_EVENT_DATA: {
        char msg[64] = {0};
        char topic[64] = {0};
        
        int msg_len = event->data_len < 63 ? event->data_len : 63;
        int top_len = event->topic_len < 63 ? event->topic_len : 63;
        
        memcpy(msg, event->data, msg_len);
        memcpy(topic, event->topic, top_len);
        
        msg[msg_len] = '\0';
        topic[top_len] = '\0';
        
        ESP_LOGI(TAG, "📩 MQTT Received on [%s]", topic);
        ESP_LOGI(TAG, "   Payload: %s | Retained: %s", msg, event->retain ? "YES" : "NO");

        if (strcmp(msg, "ON") == 0) {
            if (s_relay_state == false) {
                s_relay_state = true;
                gpio_set_level(RELAY_GPIO, 1);
                ESP_LOGI(TAG, "⚡ MQTT -> Relay switched ON");
                sync_state_to_mqtt();
            } else {
                ESP_LOGD(TAG, "Ignore ON: Already ON");
            }
        } 
        else if (strcmp(msg, "OFF") == 0) {
            if (s_relay_state == true) {
                s_relay_state = false;
                gpio_set_level(RELAY_GPIO, 0);
                ESP_LOGI(TAG, "🌑 MQTT -> Relay switched OFF");
                sync_state_to_mqtt();
            } else {
                ESP_LOGD(TAG, "Ignore OFF: Already OFF");
            }
        }
        else if (strstr(msg, "RESET_WIFI")) {
            // 🚨 BẢO VỆ: Nếu là tin nhắn retained (tin nhắn cũ lưu trên server), ta bỏ qua
            // để tránh việc thiết bị vừa kết nối đã bị reset ngay lập tức (Infinite Loop).
            if (event->retain) {
                ESP_LOGW(TAG, "⚠️ Received RETAINED RESET_WIFI message. Ignoring to avoid loop.");
                break;
            }

            ESP_LOGW(TAG, "=============================================");
            ESP_LOGW(TAG, "🚨 [MQTT] RESET WIFI COMMAND DETECTED!");
            ESP_LOGW(TAG, "📱 Source: Mobile App 'Delete Device'");
            ESP_LOGW(TAG, "🛠️ Action: ERASING ALL WIFI CREDENTIALS...");
            ESP_LOGW(TAG, "=============================================");
            
            // Xóa sạch NVS bằng cách mở namespace và xóa hết key
            nvs_handle_t h;
            if (nvs_open("storage", NVS_READWRITE, &h) == ESP_OK) {
                nvs_erase_all(h);
                nvs_commit(h);
                nvs_close(h);
            }
            // Cũng xóa đồng thời partition NVS mặc định của WiFi
            nvs_flash_erase(); 
            
            ESP_LOGW(TAG, "✅ STEP 1: NVS Data Cleared Successfully");
            
            vTaskDelay(pdMS_TO_TICKS(1500));
            ESP_LOGW(TAG, "🔄 STEP 2: Restarting System to Setup Mode...");
            ESP_LOGW(TAG, "---------------------------------------------");
            vTaskDelay(pdMS_TO_TICKS(500));
            esp_restart();
        }
        break;
    }
    default:
        break;
    }
}

static void mqtt_app_start(void) {
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = MQTT_BROKER_URL,
        .credentials = {
            .client_id = MQTT_CLIENT_ID,
            .username = MQTT_USERNAME,
            .authentication.password = MQTT_PASSWORD,
        },
        .broker.verification.crt_bundle_attach = esp_crt_bundle_attach,
    };

    s_mqtt_client = esp_mqtt_client_init(&mqtt_cfg);
    esp_mqtt_client_register_event(s_mqtt_client, ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    esp_mqtt_client_start(s_mqtt_client);
}

/* =====================================================
 *                  ACS712 TASK (CURRENT SENSOR)
 * ===================================================== */
void acs712_task(void *pvParameters)
{
    // Chờ cho đến khi MQTT được kết nối (nghĩa là đã cấu hình WiFi qua App xong)
    ESP_LOGI(TAG, "ACS712 Task: Waiting for MQTT connection before starting sensor...");
    while (s_mqtt_client == NULL) {
        vTaskDelay(pdMS_TO_TICKS(1000));
    }

    // Init ADC cho ESP32-C3 (ADC1 Channel 0 = GPIO 0)
    adc_oneshot_unit_handle_t adc_handle;
    adc_oneshot_unit_init_cfg_t init_config = {
        .unit_id = ADC_UNIT_1,
    };
    ESP_ERROR_CHECK(adc_oneshot_new_unit(&init_config, &adc_handle));

    adc_oneshot_chan_cfg_t config = {
        .bitwidth = ADC_BITWIDTH_DEFAULT,
        .atten = ADC_ATTEN_DB_12,
    };
    ESP_ERROR_CHECK(adc_oneshot_config_channel(adc_handle, ACS_CHANNEL, &config));

    ESP_LOGI(TAG, "ACS712: Starting calibration...");
    vTaskDelay(pdMS_TO_TICKS(2000)); // Chờ 2s cho hệ thống ổn định
    
    // ===== HIỆU CHUẨN ZERO POINT =====
    // Đọc 100 mẫu khi KHÔNG TẢI để tính zero point
    float zero_voltage_sum = 0;
    for (int i = 0; i < 100; i++) {
        int raw = 0;
        adc_oneshot_read(adc_handle, ACS_CHANNEL, &raw);
        float voltage = (raw / 4095.0) * 3.3;
        zero_voltage_sum += voltage;
        vTaskDelay(pdMS_TO_TICKS(10));
    }
    float zero_point = zero_voltage_sum / 100.0;
    
    ESP_LOGW(TAG, "ACS712: Zero point calibrated = %.3fV", zero_point);
    ESP_LOGI(TAG, "ACS712: Sensor ready");

    // --- THÔNG SỐ HIỆU CHUẨN (CÓ THỂ ĐIỀU CHỈNH ĐỂ KHỚP VỚI THỰC TẾ) ---
    float sensitivity = 0.100;       // ACS712-20A: 0.100V/A (Nếu dùng bản 5A thì đổi thành 0.185)
    float VOLTAGE_AC = 220.0;        // Điện áp lưới (V)
    float CALIB_FACTOR = 0.68;       // Hệ số bù sai số (Tính bằng: Công suất thực / Công suất đo được)
    float ADC_VREF = 3.3;            // Điện áp tham chiếu ADC (V)
    float last_power = 0;            // Lưu giá trị trước để lọc nhiễu
    // -----------------------------------------------------------------

    while (1) {
        float current_sum_sq = 0;
        int sample_count = 1000;      // Tăng lên 1000 mẫu (đo trong khoảng 100-200ms)
        
        // 1. Tính giá trị trung bình thực tế tại thời điểm đo (Dynamic Zero Point)
        // Điều này rất quan trọng vì Zero Point có thể bị trôi theo nhiệt độ
        float current_zero_sum = 0;
        for (int i = 0; i < 100; i++) {
            int raw = 0;
            adc_oneshot_read(adc_handle, ACS_CHANNEL, &raw);
            current_zero_sum += (raw / 4095.0) * ADC_VREF;
            esp_rom_delay_us(100);
        }
        float dynamic_zero = current_zero_sum / 100.0;

        // 2. Đo RMS dòng điện
        for (int i = 0; i < sample_count; i++) {
            int raw = 0;
            adc_oneshot_read(adc_handle, ACS_CHANNEL, &raw);
            float voltage = (raw / 4095.0) * ADC_VREF;
            
            // Lấy giá trị tức thời đã trừ nhiễu DC
            float instant_current = (voltage - dynamic_zero) / sensitivity;
            current_sum_sq += instant_current * instant_current;
            
            // Delay cực nhỏ để lấy mẫu theo hình sin (50Hz = 20ms/chu kỳ)
            // 1000 mẫu / 500us mỗi mẫu = 500ms (đo được 25 chu kỳ hình sin)
            esp_rom_delay_us(500); 
        }

        // 3. Tính toán kết quả cuối cùng
        float current_rms = sqrt(current_sum_sq / sample_count);
        
        // Áp dụng hệ số hiệu chuẩn (Calibration)
        current_rms *= CALIB_FACTOR;

        // Ngưỡng lọc nhiễu trắng (Dưới mức này coi như thiết bị đã tắt)
        if (current_rms < 0.10) current_rms = 0;
        
        float power = current_rms * VOLTAGE_AC;
        
        // Lọc nhiễu trung bình trượt (Lấy 70% giá trị mới + 30% giá trị cũ)
        // Giúp con số trên Dashboard mượt mà, không nhảy lung tung
        if (last_power > 0) {
            power = (power * 0.7) + (last_power * 0.3);
        }
        last_power = power;

        // 4. Gửi lên MQTT
        if (s_mqtt_client) {
            char json_data[64];
            snprintf(json_data, sizeof(json_data), 
                     "{\"A\":%.2f,\"W\":%.1f}", current_rms, power);
            
            esp_mqtt_client_publish(s_mqtt_client, MQTT_TOPIC_SENSOR, 
                                     json_data, 0, 0, 0);
            
            ESP_LOGI(TAG, "⚡ Power: %.2f A | %.1f W (Calibrated)", current_rms, power);
        }
        
        vTaskDelay(pdMS_TO_TICKS(2000));
    }
}

/* =====================================================
 *                  BLE & WIFI SETUP
 * ===================================================== */
// Forward declarations
static void ble_on_sync(void);
static void init_ble(void);
static int ble_gap_event(struct ble_gap_event *event, void *arg);

// Xử lý sự kiện GAP (Kết nối Bluetooth)
static int ble_gap_event(struct ble_gap_event *event, void *arg) {
    switch (event->type) {
        case BLE_GAP_EVENT_CONNECT:
            ESP_LOGI(TAG, "📱 Mobile App CONNECTED via Bluetooth (status=%d)", event->connect.status);
            break;
        case BLE_GAP_EVENT_DISCONNECT:
            ESP_LOGI(TAG, "📱 Mobile App DISCONNECTED (reason=%d)", event->disconnect.reason);
            // Tiếp tục quảng bá để App khác có thể thấy
            ble_on_sync(); 
            break;
        case BLE_GAP_EVENT_ADV_COMPLETE:
            ESP_LOGI(TAG, "BLE Advertising complete");
            break;
    }
    return 0;
}

// Logic WiFi Sync
static void ble_on_sync(void) {
    int rc;
    ble_hs_id_infer_auto(0, &ble_addr_type);

    struct ble_hs_adv_fields fields;
    memset(&fields, 0, sizeof fields);

    // Cấu hình các flag quảng bá
    fields.flags = BLE_HS_ADV_F_DISC_GEN | BLE_HS_ADV_F_BREDR_UNSUP;

    // Đưa tên thiết bị vào gói quảng bá
    fields.name = (uint8_t *)BLE_DEVICE_NAME;
    fields.name_len = strlen(BLE_DEVICE_NAME);
    fields.name_is_complete = 1;

    rc = ble_gap_adv_set_fields(&fields);
    if (rc != 0) {
        ESP_LOGE(TAG, "error setting advertisement data; rc=%d", rc);
        return;
    }

    struct ble_gap_adv_params adv_params = {0};
    adv_params.conn_mode = BLE_GAP_CONN_MODE_UND;
    adv_params.disc_mode = BLE_GAP_DISC_MODE_GEN;
    
    ESP_LOGI(TAG, "BLE: Starting advertising as %s...", BLE_DEVICE_NAME);
    rc = ble_gap_adv_start(ble_addr_type, NULL, BLE_HS_FOREVER, &adv_params, ble_gap_event, NULL);
    if (rc != 0) {
        ESP_LOGE(TAG, "error enabling advertisement; rc=%d", rc);
    }
}

// Characteristic Access Callback
static int wifi_chr_access_cb(uint16_t conn_handle, uint16_t attr_handle, struct ble_gatt_access_ctxt *ctxt, void *arg) {
    if (ctxt->op == BLE_GATT_ACCESS_OP_WRITE_CHR) {
        uint16_t len = OS_MBUF_PKTLEN(ctxt->om);
        ESP_LOGI(TAG, "📥 Received data from App via BLE (len=%d)", len);
        
        if (len > 0 && len < 256) {
            os_mbuf_copydata(ctxt->om, 0, len, ble_char_value);
            ble_char_value[len] = '\0';
            ESP_LOGI(TAG, "📥 Raw Data: %s", (char*)ble_char_value);

            cJSON *json = cJSON_Parse((char*)ble_char_value);
            if (json) {
                cJSON *ssid = cJSON_GetObjectItem(json, "ssid");
                cJSON *pass = cJSON_GetObjectItem(json, "password");
                if (cJSON_IsString(ssid) && cJSON_IsString(pass)) {
                    ESP_LOGI(TAG, "✅ WiFi Config Received: SSID=%s, PASS=******", ssid->valuestring);
                    save_wifi_credentials(ssid->valuestring, pass->valuestring);
                    set_led_color(0, 255, 0); // Xanh lá: Thành công
                    ESP_LOGI(TAG, "🔄 Restarting to apply new WiFi config...");
                    vTaskDelay(pdMS_TO_TICKS(2000));
                    esp_restart();
                } else {
                    ESP_LOGE(TAG, "❌ Invalid JSON format (missing ssid or password)");
                }
                cJSON_Delete(json);
            } else {
                ESP_LOGE(TAG, "❌ Failed to parse JSON");
            }
        }
    }
    return 0;
}

// GATT Services
static const struct ble_gatt_svc_def gatt_svcs[] = {
    {
        .type = BLE_GATT_SVC_TYPE_PRIMARY,
        .uuid = BLE_UUID16_DECLARE(0x00FF),
        .characteristics = (struct ble_gatt_chr_def[]) {
            {
                .uuid = BLE_UUID16_DECLARE(0xFF01),
                .access_cb = wifi_chr_access_cb,
                .flags = BLE_GATT_CHR_F_READ | BLE_GATT_CHR_F_WRITE,
                .val_handle = &wifi_config_handle,
            }, {0}
        },
    }, {0}
};

static void ble_host_task(void *param) { nimble_port_run(); nimble_port_freertos_deinit(); }

// Initialize BLE
static void init_ble(void) {
    ble_svc_gap_device_name_set(BLE_DEVICE_NAME);
    ble_svc_gap_init();
    ble_svc_gatt_init();
    ble_gatts_count_cfg(gatt_svcs);
    ble_gatts_add_svcs(gatt_svcs);
    nimble_port_freertos_init(ble_host_task);
}

/* =====================================================
 *                  MAIN APPLICATION
 * ===================================================== */

// Lưu/Đọc NVS
static esp_err_t save_wifi_credentials(const char *ssid, const char *password) {
    nvs_handle_t h;
    nvs_open("storage", NVS_READWRITE, &h);
    nvs_set_str(h, "ssid", ssid);
    nvs_set_str(h, "password", password);
    nvs_commit(h);
    nvs_close(h);
    return ESP_OK;
}

// Sự kiện WiFi
static void wifi_event_handler(void* arg, esp_event_base_t event_base, int32_t event_id, void* event_data) {
    if (event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_id == WIFI_EVENT_STA_DISCONNECTED) {
        esp_wifi_connect(); // Retry forever
        set_led_color(255, 165, 0); // Cam: Đang connect lại
    } else if (event_id == IP_EVENT_STA_GOT_IP) {
        // Start MQTT
        mqtt_app_start();
    }
}

void app_main(void) {
    // 1. Init Hardware
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    
    esp_netif_init();
    esp_event_loop_create_default();
    
    gpio_reset_pin(RELAY_GPIO);
    gpio_set_direction(RELAY_GPIO, GPIO_MODE_OUTPUT);
    gpio_set_level(RELAY_GPIO, 0); // ACTIVE HIGH: 0 = TẮT ban đầu
    
    configure_led();
    set_led_color(50, 50, 50); // Trắng khởi động

    // 2. Load WiFi
    char ssid[32] = {0}; char pass[64] = {0};
    
    // --- LOGIC TEST MODE ---
    if (FORCE_TEST_MODE) {
        ESP_LOGW(TAG, ">>> ĐANG CHẠY CHẾ ĐỘ TEST (Hardcoded WiFi) <<<");
        strcpy(ssid, TEST_WIFI_SSID);
        strcpy(pass, TEST_WIFI_PASS);
    } 
    else {
        // Mặc định: Lấy từ bộ nhớ NVS
        size_t len;
        nvs_handle_t h;
        if (nvs_open("storage", NVS_READONLY, &h) == ESP_OK) {
            len = 32; nvs_get_str(h, "ssid", ssid, &len);
            len = 64; nvs_get_str(h, "password", pass, &len);
            nvs_close(h);
        }
    }
    // -----------------------

    if (strlen(ssid) > 0) {
        // Mode: STATION (Đã có WiFi)
        ESP_LOGI(TAG, "Connecting to WiFi: %s", ssid);
        esp_netif_create_default_wifi_sta();
        wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
        esp_wifi_init(&cfg);
        esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifi_event_handler, NULL);
        esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &wifi_event_handler, NULL);
        
        wifi_config_t wifi_config = {0};
        strcpy((char*)wifi_config.sta.ssid, ssid);
        strcpy((char*)wifi_config.sta.password, pass);
        esp_wifi_set_mode(WIFI_MODE_STA);
        esp_wifi_set_config(WIFI_IF_STA, &wifi_config);
        esp_wifi_start();
    } else {
        // Mode: SETUP (Chưa có WiFi -> Mở BLE)
        ESP_LOGI(TAG, "=============================================");
        ESP_LOGI(TAG, "📶 DEVICE IN PROVISIONING MODE (SETUP)");
        ESP_LOGI(TAG, "📱 Please open the Mobile App to configure WiFi");
        ESP_LOGI(TAG, "=============================================");
        set_led_color(255, 0, 255); // Tím: Mode Setup
        
        nimble_port_init(); 
        ble_hs_cfg.sync_cb = ble_on_sync;
        init_ble(); // Start BLE
    }

    // 3. Start Tasks
    xTaskCreate(button_task, "button_task", 4096, NULL, 10, NULL);
    xTaskCreate(acs712_task, "acs712_task", 4096, NULL, 5, NULL);
}
