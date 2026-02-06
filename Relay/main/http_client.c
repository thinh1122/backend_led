// HTTP Client cho ESP32 - Thay thế MQTT
#include "esp_http_client.h"
#include "esp_log.h"
#include "esp_crt_bundle.h"  // ⚡ Thêm để dùng esp_crt_bundle_attach
#include "cJSON.h"
#include <string.h>

static const char *TAG_HTTP = "HTTP_CLIENT";

// Buffer cho HTTP response
#define MAX_HTTP_OUTPUT_BUFFER 2048
static char http_response_buffer[MAX_HTTP_OUTPUT_BUFFER];
static int http_response_len = 0;

// HTTP event handler
esp_err_t http_event_handler(esp_http_client_event_t *evt) {
    switch(evt->event_id) {
        case HTTP_EVENT_ON_DATA:
            if (http_response_len + evt->data_len < MAX_HTTP_OUTPUT_BUFFER) {
                memcpy(http_response_buffer + http_response_len, evt->data, evt->data_len);
                http_response_len += evt->data_len;
            }
            break;
        default:
            break;
    }
    return ESP_OK;
}

// POST state to backend
void http_post_device_state(const char *device_id, bool state, float current, float power) {
    char url[256];
    snprintf(url, sizeof(url), "http://192.168.1.74:8080/api/devices/%s/state", device_id);
    
    // Tạo JSON payload
    cJSON *root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "state", state ? "ON" : "OFF");
    cJSON_AddNumberToObject(root, "current", current);
    cJSON_AddNumberToObject(root, "power", power);
    char *post_data = cJSON_PrintUnformatted(root);
    
    esp_http_client_config_t config = {
        .url = url,
        .method = HTTP_METHOD_POST,
        .event_handler = http_event_handler,
        .timeout_ms = 5000,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&config);
    esp_http_client_set_header(client, "Content-Type", "application/json");
    esp_http_client_set_post_field(client, post_data, strlen(post_data));
    
    esp_err_t err = esp_http_client_perform(client);
    if (err == ESP_OK) {
        ESP_LOGI(TAG_HTTP, "✅ POST state: %s (%.2fA, %.1fW)", state ? "ON" : "OFF", current, power);
    } else {
        ESP_LOGW(TAG_HTTP, "⚠️ POST failed: %s", esp_err_to_name(err));
    }
    
    esp_http_client_cleanup(client);
    cJSON_Delete(root);
    free(post_data);
}

// GET command from backend
bool http_get_device_command(const char *device_id, bool *out_state) {
    char url[256];
    snprintf(url, sizeof(url), "http://192.168.1.74:8080/api/devices/%s/command", device_id);
    
    http_response_len = 0;
    memset(http_response_buffer, 0, MAX_HTTP_OUTPUT_BUFFER);
    
    esp_http_client_config_t config = {
        .url = url,
        .method = HTTP_METHOD_GET,
        .event_handler = http_event_handler,
        .timeout_ms = 5000,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&config);
    esp_err_t err = esp_http_client_perform(client);
    
    bool success = false;
    if (err == ESP_OK && http_response_len > 0) {
        http_response_buffer[http_response_len] = '\0';
        
        // Parse JSON response
        cJSON *root = cJSON_Parse(http_response_buffer);
        if (root) {
            cJSON *state_json = cJSON_GetObjectItem(root, "state");
            if (state_json && cJSON_IsString(state_json)) {
                *out_state = (strcmp(state_json->valuestring, "ON") == 0);
                success = true;
                ESP_LOGI(TAG_HTTP, "📥 GET command: %s", *out_state ? "ON" : "OFF");
            }
            cJSON_Delete(root);
        }
    }
    
    esp_http_client_cleanup(client);
    return success;
}
