#ifndef VOICE_CONTROL_H
#define VOICE_CONTROL_H

#include "esp_err.h"
#include "driver/i2s_std.h"

/* =====================================================
 *                  VOICE CONTROL CONFIG
 * ===================================================== */
#define I2S_DATA_GPIO     GPIO_NUM_4   // SD pin
#define I2S_WS_GPIO       GPIO_NUM_5   // WS pin  
#define I2S_SCK_GPIO      GPIO_NUM_6   // SCK pin

#define SAMPLE_RATE       16000        // 16kHz
#define SAMPLE_BITS       16           // 16-bit
#define BUFFER_SIZE       1024         // Buffer size

// Voice commands
typedef enum {
    VOICE_CMD_NONE = 0,
    VOICE_CMD_TURN_ON,
    VOICE_CMD_TURN_OFF,
    VOICE_CMD_TOGGLE
} voice_command_t;

/* =====================================================
 *                  FUNCTION DECLARATIONS
 * ===================================================== */

/**
 * Initialize I2S microphone
 */
esp_err_t voice_control_init(void);

/**
 * Start voice recognition task
 */
void voice_control_start(void);

/**
 * Stop voice recognition
 */
void voice_control_stop(void);

/**
 * Process audio data and detect commands
 */
voice_command_t voice_process_audio(int16_t* audio_data, size_t samples);

/**
 * Set callback for voice commands
 */
void voice_set_command_callback(void (*callback)(voice_command_t cmd));

#endif // VOICE_CONTROL_H