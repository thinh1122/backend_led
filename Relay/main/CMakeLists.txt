idf_component_register(SRCS "blink_example_main.c"
                       INCLUDE_DIRS "."
                       REQUIRES esp_wifi esp_event nvs_flash esp_netif mqtt esp_adc driver wifi_provisioning bt esp_http_server json)
