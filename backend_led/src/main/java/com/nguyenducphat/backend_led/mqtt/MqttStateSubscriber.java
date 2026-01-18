package com.nguyenducphat.backend_led.mqtt;

import com.nguyenducphat.backend_led.entity.Device;
import com.nguyenducphat.backend_led.repository.DeviceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.messaging.MessageHandler;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class MqttStateSubscriber {

    private final DeviceRepository deviceRepository;

    @Bean
    @ServiceActivator(inputChannel = "mqttInboundChannel")
    public MessageHandler handler() {
        return message -> {
            String topic = message.getHeaders().get("mqtt_receivedTopic", String.class);
            String payload = (String) message.getPayload();
            
            System.out.println("📩 Backend MQTT Inbound: " + topic + " -> " + payload);

            if (topic != null && topic.contains("/state")) {
                // Topic format: smarthome/devices/{hardwareId}/state
                String[] parts = topic.split("/");
                if (parts.length >= 3) {
                    String hardwareId = parts[2];
                    updateDeviceState(hardwareId, payload);
                }
            }
        };
    }

    private void updateDeviceState(String hardwareId, String state) {
        boolean isOn = state.equalsIgnoreCase("ON");
        
        deviceRepository.findByHardwareId(hardwareId).ifPresent(device -> {
            if (device.isOn() != isOn) {
                device.setOn(isOn);
                deviceRepository.save(device);
                System.out.println("✅ Sync Database: Device [" + hardwareId + "] updated to " + state);
            }
        });
    }
}
