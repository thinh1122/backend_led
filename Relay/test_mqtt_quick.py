#!/usr/bin/env python3
"""
Script test MQTT nhanh - Gửi lệnh và lắng nghe phản hồi
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
TOPIC_CONTROL = f"smarthome/devices/{DEVICE_ID}/set"
TOPIC_STATE = f"smarthome/devices/{DEVICE_ID}/state"
TOPIC_SENSOR = f"smarthome/devices/{DEVICE_ID}/sensor"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Kết nối MQTT thành công!")
        print(f"📡 Subscribe: {TOPIC_STATE}")
        print(f"📡 Subscribe: {TOPIC_SENSOR}")
        client.subscribe(TOPIC_STATE, qos=1)
        client.subscribe(TOPIC_SENSOR, qos=1)
        print("\n🎯 Sẵn sàng gửi lệnh!")
    else:
        print(f"❌ Kết nối thất bại (code: {rc})")

def on_message(client, userdata, msg):
    print(f"\n📩 Nhận phản hồi:")
    print(f"   Topic: {msg.topic}")
    print(f"   Payload: {msg.payload.decode()}")
    print(f"   QoS: {msg.qos}")
    print(f"   Retained: {msg.retain}")

def main():
    client = mqtt.Client(client_id="PythonTest_" + str(int(time.time())))
    client.username_pw_set(USERNAME, PASSWORD)
    
    # SSL/TLS
    client.tls_set(cert_reqs=ssl.CERT_REQUIRED, tls_version=ssl.PROTOCOL_TLS)
    
    client.on_connect = on_connect
    client.on_message = on_message
    
    print(f"🔌 Đang kết nối tới {BROKER}:{PORT}...")
    client.connect(BROKER, PORT, 60)
    
    client.loop_start()
    
    print("\n" + "="*50)
    print("MENU:")
    print("  1 - Gửi ON")
    print("  2 - Gửi OFF")
    print("  3 - Gửi RESET_WIFI")
    print("  q - Thoát")
    print("="*50)
    
    try:
        while True:
            cmd = input("\nNhập lệnh (1/2/3/q): ").strip()
            
            if cmd == "1":
                print(f"📤 Gửi ON → {TOPIC_CONTROL}")
                client.publish(TOPIC_CONTROL, "ON", qos=1)
            elif cmd == "2":
                print(f"📤 Gửi OFF → {TOPIC_CONTROL}")
                client.publish(TOPIC_CONTROL, "OFF", qos=1)
            elif cmd == "3":
                print(f"📤 Gửi RESET_WIFI → {TOPIC_CONTROL}")
                client.publish(TOPIC_CONTROL, "RESET_WIFI", qos=1)
            elif cmd.lower() == "q":
                break
            else:
                print("❌ Lệnh không hợp lệ!")
                
    except KeyboardInterrupt:
        print("\n\n👋 Đang thoát...")
    
    client.loop_stop()
    client.disconnect()

if __name__ == "__main__":
    main()
