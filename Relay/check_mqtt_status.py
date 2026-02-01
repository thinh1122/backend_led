#!/usr/bin/env python3
"""
Kiểm tra ESP32 có còn online MQTT không
"""
import paho.mqtt.client as mqtt
import ssl
import time

BROKER = "cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud"
PORT = 8883
USERNAME = "smarthome"
PASSWORD = "Smarthome123"
TOPIC_STATE = "smarthome/devices/thiet_bi_esp32/state"

received_message = False

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Kết nối MQTT thành công!")
        client.subscribe(TOPIC_STATE)
        print(f"📡 Đang lắng nghe: {TOPIC_STATE}")
        print("⏳ Đợi 5 giây để xem ESP32 có gửi message không...\n")
    else:
        print(f"❌ Kết nối thất bại! Code: {rc}")

def on_message(client, userdata, msg):
    global received_message
    received_message = True
    print(f"📩 ESP32 ĐANG ONLINE!")
    print(f"   Topic: {msg.topic}")
    print(f"   Payload: {msg.payload.decode()}")
    print(f"   Retained: {msg.retain}")
    print("\n❌ ESP32 VẪN CÒN KẾT NỐI WIFI!")
    print("💡 WiFi chưa bị xóa hoặc ESP32 đã kết nối lại WiFi cũ")

client = mqtt.Client()
client.username_pw_set(USERNAME, PASSWORD)
client.tls_set(cert_reqs=ssl.CERT_REQUIRED, tls_version=ssl.PROTOCOL_TLS)
client.on_connect = on_connect
client.on_message = on_message

print("=" * 60)
print("   KIỂM TRA ESP32 CÓ ONLINE MQTT KHÔNG")
print("=" * 60)
print(f"🔌 Đang kết nối tới {BROKER}:{PORT}...\n")

try:
    client.connect(BROKER, PORT, 60)
    client.loop_start()
    
    # Đợi 5 giây
    time.sleep(5)
    
    if not received_message:
        print("=" * 60)
        print("✅ ESP32 OFFLINE - KHÔNG CÓ MESSAGE!")
        print("🔵 ESP32 đã xóa WiFi và đang ở chế độ BLUETOOTH")
        print("📱 Bây giờ có thể quét Bluetooth: PROV_thiet_bi_esp32")
        print("=" * 60)
    
    client.loop_stop()
    client.disconnect()

except Exception as e:
    print(f"❌ Lỗi: {e}")
