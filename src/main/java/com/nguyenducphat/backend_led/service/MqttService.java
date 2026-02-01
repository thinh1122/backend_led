package com.nguyenducphat.backend_led.service;

import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;

@Service
@Slf4j
public class MqttService {
    
    @Value("${mqtt.broker:ssl://cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud:8883}")
    private String broker;
    
    @Value("${mqtt.username:smarthome}")
    private String username;
    
    @Value("${mqtt.password:Smarthome123}")
    private String password;
    
    @Value("${mqtt.client-id:backend-scheduler}")
    private String clientId;
    
    private MqttClient mqttClient;
    
    @PostConstruct
    public void connect() {
        try {
            mqttClient = new MqttClient(broker, clientId + "-" + System.currentTimeMillis());
            
            MqttConnectOptions options = new MqttConnectOptions();
            options.setUserName(username);
            options.setPassword(password.toCharArray());
            options.setCleanSession(true);
            options.setAutomaticReconnect(true);
            options.setConnectionTimeout(10);
            options.setKeepAliveInterval(60);
            
            mqttClient.connect(options);
            log.info("✅ MQTT Connected to {}", broker);
            
        } catch (MqttException e) {
            log.error("❌ MQTT Connection failed: {}", e.getMessage());
        }
    }
    
    @PreDestroy
    public void disconnect() {
        try {
            if (mqttClient != null && mqttClient.isConnected()) {
                mqttClient.disconnect();
                mqttClient.close();
                log.info("👋 MQTT Disconnected");
            }
        } catch (MqttException e) {
            log.error("❌ MQTT Disconnect error: {}", e.getMessage());
        }
    }
    
    /**
     * Gửi message tới MQTT topic
     */
    public void publish(String topic, String payload) {
        try {
            if (mqttClient == null || !mqttClient.isConnected()) {
                log.warn("⚠️ MQTT not connected, reconnecting...");
                connect();
            }
            
            MqttMessage message = new MqttMessage(payload.getBytes());
            message.setQos(1); // QoS 1: At least once
            message.setRetained(false);
            
            mqttClient.publish(topic, message);
            log.debug("📤 MQTT Published: {} -> {}", topic, payload);
            
        } catch (MqttException e) {
            log.error("❌ MQTT Publish failed: {} - {}", topic, e.getMessage());
            throw new RuntimeException("Failed to publish MQTT message", e);
        }
    }
    
    /**
     * Kiểm tra kết nối MQTT
     */
    public boolean isConnected() {
        return mqttClient != null && mqttClient.isConnected();
    }
}
