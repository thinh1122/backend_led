idf_component_register(SRCS "voice_control.c" "blink_example_main.c" "http_client.c"
                       INCLUDE_DIRS "."
                       PRIV_REQUIRES nvs_flash esp_wifi esp_event esp_http_client mqtt espressif__led_strip driver wifi_provisioning wifi_provisioning bt esp_http_server json esp_http_client esp_coex)
