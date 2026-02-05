package com.nguyenducphat.backend_led.config;

import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;

@Configuration
public class MqttConfig {

    @Bean
    public MqttPahoClientFactory mqttClientFactory() {
        DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();
        MqttConnectOptions options = new MqttConnectOptions();
        
        // ⚡ OPTION 1: HiveMQ Cloud (Mặc định)
        options.setServerURIs(new String[] { "ssl://cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud:8883" });
        options.setUserName("smarthome");
        options.setPassword("Smarthome123".toCharArray());
        
        // ⚡ OPTION 2: Mosquitto Local (Uncomment để dùng)
        // options.setServerURIs(new String[] { "tcp://mqtt:1883" }); // "mqtt" là tên service trong docker-compose
        // Không cần username/password vì allow_anonymous=true
        
        options.setCleanSession(true);
        options.setKeepAliveInterval(30);
        
        factory.setConnectionOptions(options);
        return factory;
    }

    // --- OUTBOUND (Gửi lệnh) ---
    @Bean
    public MessageChannel mqttOutboundChannel() {
        return new DirectChannel();
    }

    @Bean
    @ServiceActivator(inputChannel = "mqttOutboundChannel")
    public MessageHandler mqttOutbound() {
        MqttPahoMessageHandler messageHandler =
                new MqttPahoMessageHandler("backend_publisher", mqttClientFactory());
        messageHandler.setAsync(true);
        return messageHandler;
    }

    // --- INBOUND (Lắng nghe trạng thái để sync Database) ---
    @Bean
    public MessageChannel mqttInboundChannel() {
        return new DirectChannel();
    }

    @Bean
    public org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter inbound() {
        org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter adapter =
                new org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter(
                        "backend_subscriber", mqttClientFactory(), "smarthome/devices/+/state");
        adapter.setCompletionTimeout(5000);
        adapter.setConverter(new org.springframework.integration.mqtt.support.DefaultPahoMessageConverter());
        adapter.setQos(1);
        adapter.setOutputChannel(mqttInboundChannel());
        adapter.setAutoStartup(true); // Auto-connect on startup
        adapter.setRecoveryInterval(10000); // Retry every 10s if connection fails
        return adapter;
    }
}
