#!/usr/bin/env python3
"""
Script test MQTT cho ESP32 Smart Plug
"""

import paho.mqtt.client as mqtt
import time
import ssl

# Cấu hình HiveMQ Cloud
BROKER = "cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud"
PORT = 8883
USERNAME = "smarthome"
PASSWORD = "Smarthome123"

DEVICE_ID = "thiet_bi_esp32"
TOPIC_SET = f"smarthome/devices/{DEVICE_ID}/set"
TOPIC_STATE = f"smarthome/devices/{DEVICE_ID}/state"
TOPIC_SENSOR = f"smarthome/devices/{DEVICE_ID}/sensor"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Kết nối MQTT thành công!")
        print(f"📡 Subscribe: {TOPIC_STATE}")
        print(f"📡 Subscribe: {TOPIC_SENSOR}")
        client.subscribe(TOPIC_STATE)
        client.subscribe(TOPIC_SENSOR)
    else:
        print(f"❌ Kết nối thất bại, code: {rc}")

def on_message(client, userdata, msg):
    print(f"📩 [{msg.topic}] {msg.payload.decode()}")

def main():
    print("=" * 60)
    print("🧪 ESP32 Smart Plug MQTT Test")
    print("=" * 60)
    
    # Tạo MQTT client
    client = mqtt.Client()
    client.username_pw_set(USERNAME, PASSWORD)
    
    # Cấu hình SSL/TLS
    client.tls_set(cert_reqs=ssl.CERT_REQUIRED, tls_version=ssl.PROTOCOL_TLS)
    
    # Callback
    client.on_connect = on_connect
    client.on_message = on_message
    
    # Kết nối
    print(f"🔌 Đang kết nối tới {BROKER}:{PORT}...")
    try:
        client.connect(BROKER, PORT, 60)
        client.loop_start()
        
        time.sleep(2)
        
        # Menu test
        while True:
            print("\n" + "=" * 60)
            print("Chọn lệnh test:")
            print("  1. Bật relay (ON)")
            print("  2. Tắt relay (OFF)")
            print("  3. Xem trạng thái (chỉ lắng nghe)")
            print("  0. Thoát")
            print("=" * 60)
            
            choice = input("Nhập lựa chọn: ").strip()
            
            if choice == "1":
                print("⚡ Gửi lệnh: ON")
                client.publish(TOPIC_SET, "ON", qos=1)
            elif choice == "2":
                print("🌑 Gửi lệnh: OFF")
                client.publish(TOPIC_SET, "OFF", qos=1)
            elif choice == "3":
                print("👂 Đang lắng nghe... (Ctrl+C để dừng)")
                time.sleep(10)
            elif choice == "0":
                break
            else:
                print("❌ Lựa chọn không hợp lệ")
        
        client.loop_stop()
        client.disconnect()
        print("\n👋 Đã ngắt kết nối")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n👋 Thoát chương trình")
