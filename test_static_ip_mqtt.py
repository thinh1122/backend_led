#!/usr/bin/env python3
"""
Test MQTT connection với ESP32 IP tĩnh
"""

import paho.mqtt.client as mqtt
import time
import json

# MQTT Configuration - Eclipse Mosquitto
MQTT_BROKER = "test.mosquitto.org"
MQTT_PORT = 1883
MQTT_USERNAME = ""  # No auth
MQTT_PASSWORD = ""  # No auth

# Device topics
DEVICE_ID = "thiet_bi_esp32"
TOPIC_COMMAND = f"smarthome/devices/{DEVICE_ID}/set"
TOPIC_STATE = f"smarthome/devices/{DEVICE_ID}/state"
TOPIC_SENSOR = f"smarthome/devices/{DEVICE_ID}/sensor"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Connected to MQTT broker")
        print(f"📡 ESP32 Static IP: 192.168.1.33")
        print(f"🎯 Device ID: {DEVICE_ID}")
        
        # Subscribe to device state and sensor
        client.subscribe(TOPIC_STATE)
        client.subscribe(TOPIC_SENSOR)
        print(f"📥 Subscribed to: {TOPIC_STATE}")
        print(f"📥 Subscribed to: {TOPIC_SENSOR}")
        
    else:
        print(f"❌ Failed to connect, return code {rc}")

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode()
    
    if topic == TOPIC_STATE:
        print(f"🔌 Device State: {payload}")
    elif topic == TOPIC_SENSOR:
        try:
            sensor_data = json.loads(payload)
            current = sensor_data.get('A', 0)
            power = sensor_data.get('W', 0)
            print(f"⚡ Power: {current:.2f}A | {power:.1f}W")
        except:
            print(f"📊 Sensor: {payload}")

def test_commands():
    """Test các lệnh điều khiển"""
    
    client = mqtt.Client()
    # No authentication needed for test.mosquitto.org
    # client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
    # client.tls_set()  # No TLS needed
    
    client.on_connect = on_connect
    client.on_message = on_message
    
    try:
        print("🔗 Connecting to MQTT broker...")
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_start()
        
        time.sleep(2)  # Wait for connection
        
        print("\n🧪 Testing commands...")
        
        # Test ON command
        print("📤 Sending: ON")
        client.publish(TOPIC_COMMAND, "ON")
        time.sleep(3)
        
        # Test OFF command  
        print("📤 Sending: OFF")
        client.publish(TOPIC_COMMAND, "OFF")
        time.sleep(3)
        
        # Test ON again
        print("📤 Sending: ON")
        client.publish(TOPIC_COMMAND, "ON")
        time.sleep(3)
        
        print("\n✅ Test completed! Check ESP32 relay status.")
        
        # Keep listening for 10 more seconds
        print("👂 Listening for sensor data...")
        time.sleep(10)
        
    except Exception as e:
        print(f"❌ Error: {e}")
    finally:
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    test_commands()