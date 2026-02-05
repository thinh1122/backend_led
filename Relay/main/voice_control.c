#include "voice_control.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/i2s_std.h"
#include <string.h>
#include <math.h>

static const char *TAG = "VOICE_CONTROL";

static i2s_chan_handle_t rx_handle = NULL;
static TaskHandle_t voice_task_handle = NULL;
static bool voice_active = false;
static void (*command_callback)(voice_command_t) = NULL;

// Debouncing variables to prevent command spam
static uint32_t last_command_time = 0;
static voice_command_t last_command = VOICE_CMD_NONE;
static const uint32_t COMMAND_DEBOUNCE_MS = 2000; // 2 seconds between same commands

/* =====================================================
 *                  VOICE DETECTION LOGIC
 * ===================================================== */

/**
 * Simple voice activity detection based on energy
 */
static bool detect_voice_activity(int16_t* audio_data, size_t samples) {
    float energy = 0.0f;
    for (size_t i = 0; i < samples; i++) {
        energy += (float)(audio_data[i] * audio_data[i]);
    }
    energy = energy / samples;
    
    // Voice activity threshold (energy). Lower value = nhạy hơn
    const float VOICE_THRESHOLD = 2000000.0f; // Giảm từ 5_000_000.0 xuống 2_000_000.0
    return energy > VOICE_THRESHOLD;
}

/**
 * Simple pattern matching for voice commands
 * This is a basic implementation - in real project you'd use ML/AI
 */
static voice_command_t detect_voice_command(int16_t* audio_data, size_t samples) {
    // Calculate zero crossing rate (simple feature)
    int zero_crossings = 0;
    for (size_t i = 1; i < samples; i++) {
        if ((audio_data[i-1] >= 0 && audio_data[i] < 0) || 
            (audio_data[i-1] < 0 && audio_data[i] >= 0)) {
            zero_crossings++;
        }
    }
    
    float zcr = (float)zero_crossings / samples;
    
    // More restrictive ZCR thresholds to reduce false positives
    // "Bật" typically has ZCR 0.15-0.35, "Tắt" has ZCR 0.05-0.15
    if (zcr >= 0.15f && zcr <= 0.35f) {
        ESP_LOGI(TAG, "🎤 Detected: TURN ON command (ZCR: %.3f)", zcr);
        return VOICE_CMD_TURN_ON;
    } else if (zcr >= 0.05f && zcr < 0.15f) {
        ESP_LOGI(TAG, "🎤 Detected: TURN OFF command (ZCR: %.3f)", zcr);
        return VOICE_CMD_TURN_OFF;
    }
    
    // Log unrecognized patterns for debugging
    ESP_LOGD(TAG, "🎤 Unrecognized voice pattern (ZCR: %.3f)", zcr);
    return VOICE_CMD_NONE;
}

/* =====================================================
 *                  VOICE PROCESSING TASK
 * ===================================================== */

static void voice_task(void *pvParameters) {
    int16_t *audio_buffer = malloc(BUFFER_SIZE * sizeof(int16_t));
    if (!audio_buffer) {
        ESP_LOGE(TAG, "Failed to allocate audio buffer");
        vTaskDelete(NULL);
        return;
    }
    
    ESP_LOGI(TAG, "🎤 Voice recognition task started");
    
    while (voice_active) {
        size_t bytes_read = 0;
        
        // Read audio data from I2S
        esp_err_t ret = i2s_channel_read(rx_handle, audio_buffer, 
                                        BUFFER_SIZE * sizeof(int16_t), 
                                        &bytes_read, portMAX_DELAY);
        
        if (ret == ESP_OK && bytes_read > 0) {
            size_t samples = bytes_read / sizeof(int16_t);
            
            // Check for voice activity
            if (detect_voice_activity(audio_buffer, samples)) {
                ESP_LOGI(TAG, "🎤 Voice activity detected!");
                
                // Try to detect command
                voice_command_t cmd = detect_voice_command(audio_buffer, samples);
                if (cmd != VOICE_CMD_NONE) {
                    // Debouncing: prevent same command spam
                    uint32_t current_time = xTaskGetTickCount() * portTICK_PERIOD_MS;
                    if (cmd != last_command || (current_time - last_command_time) > COMMAND_DEBOUNCE_MS) {
                        if (command_callback) {
                            command_callback(cmd);
                        }
                        last_command = cmd;
                        last_command_time = current_time;
                    } else {
                        ESP_LOGD(TAG, "🎤 Command ignored (debouncing)");
                    }
                }
            }
        }
        
        vTaskDelay(pdMS_TO_TICKS(50)); // 50ms delay
    }
    
    free(audio_buffer);
    ESP_LOGI(TAG, "🎤 Voice recognition task stopped");
    vTaskDelete(NULL);
}

/* =====================================================
 *                  PUBLIC FUNCTIONS
 * ===================================================== */

esp_err_t voice_control_init(void) {
    ESP_LOGI(TAG, "🎤 Initializing I2S microphone...");
    
    // I2S channel configuration - use specific I2S port
    i2s_chan_config_t chan_cfg = I2S_CHANNEL_DEFAULT_CONFIG(I2S_NUM_0, I2S_ROLE_MASTER);
    esp_err_t ret = i2s_new_channel(&chan_cfg, NULL, &rx_handle);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to create I2S channel: %s", esp_err_to_name(ret));
        return ret;
    }
    
    // I2S standard configuration
    i2s_std_config_t std_cfg = {
        .clk_cfg = I2S_STD_CLK_DEFAULT_CONFIG(SAMPLE_RATE),
        .slot_cfg = I2S_STD_MSB_SLOT_DEFAULT_CONFIG(I2S_DATA_BIT_WIDTH_16BIT, I2S_SLOT_MODE_MONO),
        .gpio_cfg = {
            .mclk = I2S_GPIO_UNUSED,
            .bclk = I2S_SCK_GPIO,
            .ws = I2S_WS_GPIO,
            .dout = I2S_GPIO_UNUSED,
            .din = I2S_DATA_GPIO,
            .invert_flags = {
                .mclk_inv = false,
                .bclk_inv = false,
                .ws_inv = false,
            },
        },
    };
    
    ret = i2s_channel_init_std_mode(rx_handle, &std_cfg);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to initialize I2S standard mode: %s", esp_err_to_name(ret));
        return ret;
    }
    
    // Enable I2S channel
    ret = i2s_channel_enable(rx_handle);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to enable I2S channel: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ESP_LOGI(TAG, "✅ I2S microphone initialized successfully");
    return ESP_OK;
}

void voice_control_start(void) {
    if (voice_active) {
        ESP_LOGW(TAG, "Voice control already active");
        return;
    }
    
    voice_active = true;
    
    // Create voice processing task
    BaseType_t ret = xTaskCreate(voice_task, "voice_task", 4096, NULL, 5, &voice_task_handle);
    if (ret != pdPASS) {
        ESP_LOGE(TAG, "Failed to create voice task");
        voice_active = false;
        return;
    }
    
    ESP_LOGI(TAG, "🎤 Voice control started");
}

void voice_control_stop(void) {
    if (!voice_active) {
        return;
    }
    
    voice_active = false;
    
    // Stop task first
    if (voice_task_handle) {
        vTaskDelete(voice_task_handle);
        voice_task_handle = NULL;
    }
    
    // Cleanup I2S channel
    if (rx_handle) {
        i2s_channel_disable(rx_handle);
        i2s_del_channel(rx_handle);
        rx_handle = NULL;
        ESP_LOGI(TAG, "🎤 I2S channel cleaned up");
    }
    
    ESP_LOGI(TAG, "🎤 Voice control stopped");
}

voice_command_t voice_process_audio(int16_t* audio_data, size_t samples) {
    if (!audio_data || samples == 0) {
        return VOICE_CMD_NONE;
    }
    
    if (detect_voice_activity(audio_data, samples)) {
        return detect_voice_command(audio_data, samples);
    }
    
    return VOICE_CMD_NONE;
}

void voice_set_command_callback(void (*callback)(voice_command_t cmd)) {
    command_callback = callback;
}