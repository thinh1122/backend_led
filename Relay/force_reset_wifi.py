#!/usr/bin/env python3
"""
Gửi lệnh RESET_WIFI nhiều lần để đảm bảo ESP32 nhận được
"""
import paho.mqtt.client as mqtt
import ssl
import time

BROKER = "cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud"
PORT = 8883
USERNAME = "smarthome"
PASSWORD = "Smarthome123"
TOPIC_SET = "smarthome/devices/thiet_bi_esp32/set"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Kết nối MQTT thành công!")
    else:
        print(f"❌ Kết nối thất bại! Code: {rc}")

client = mqtt.Client()
client.username_pw_set(USERNAME, PASSWORD)
client.tls_set(cert_reqs=ssl.CERT_REQUIRED, tls_version=ssl.PROTOCOL_TLS)
client.on_connect = on_connect

print("=" * 60)
print("   GỬI LỆNH RESET_WIFI (x5 LẦN)")
print("=" * 60)
print(f"🔌 Đang kết nối tới {BROKER}:{PORT}...\n")

try:
    client.connect(BROKER, PORT, 60)
    client.loop_start()
    time.sleep(2)
    
    # Gửi 5 lần để chắc chắn
    for i in range(5):
        print(f"📡 [{i+1}/5] Gửi lệnh RESET_WIFI...")
        client.publish(TOPIC_SET, "RESET_WIFI", qos=1)
        time.sleep(1)
    
    print("\n✅ Đã gửi 5 lần!")
    print("⏳ ESP32 sẽ xóa WiFi và restart trong 10 giây...")
    print("📱 Sau đó mở App để quét Bluetooth: PROV_thiet_bi_esp32")
    
    client.loop_stop()
    client.disconnect()

except Exception as e:
    print(f"❌ Lỗi: {e}")
