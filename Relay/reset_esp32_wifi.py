#!/usr/bin/env python3
"""
Script gửi lệnh RESET_WIFI tới ESP32 qua MQTT
"""

import paho.mqtt.client as mqtt
import ssl
import time

BROKER = "cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud"
PORT = 8883
USERNAME = "smarthome"
PASSWORD = "Smarthome123"

DEVICE_ID = "thiet_bi_esp32"
TOPIC_SET = f"smarthome/devices/{DEVICE_ID}/set"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Kết nối MQTT thành công!")
        print(f"📡 Gửi lệnh RESET_WIFI tới {TOPIC_SET}")
        
        # Gửi lệnh reset WiFi (không retained để tránh loop)
        client.publish(TOPIC_SET, "RESET_WIFI", qos=1, retain=False)
        
        print("✅ Đã gửi lệnh RESET_WIFI")
        print("⏳ ESP32 sẽ xóa WiFi và restart trong vài giây...")
        print("📱 Sau đó mở App để quét Bluetooth lại")
        
        time.sleep(2)
        client.disconnect()
    else:
        print(f"❌ Kết nối thất bại, code: {rc}")

def main():
    print("=" * 60)
    print("🔄 Reset WiFi ESP32 qua MQTT")
    print("=" * 60)
    
    client = mqtt.Client()
    client.username_pw_set(USERNAME, PASSWORD)
    client.tls_set(cert_reqs=ssl.CERT_REQUIRED, tls_version=ssl.PROTOCOL_TLS)
    client.on_connect = on_connect
    
    print(f"🔌 Đang kết nối tới {BROKER}:{PORT}...")
    try:
        client.connect(BROKER, PORT, 60)
        client.loop_forever()
        print("\n👋 Hoàn tất!")
    except Exception as e:
        print(f"❌ Lỗi: {e}")

if __name__ == "__main__":
    main()
