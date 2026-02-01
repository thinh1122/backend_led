#!/usr/bin/env python3
"""
Script để kiểm tra trạng thái ESP32 - Bluetooth có đang bật không
"""
import serial
import time
import sys

PORT = 'COM6'
BAUD = 115200

print("=" * 60)
print("   KIỂM TRA TRẠNG THÁI ESP32 BLUETOOTH")
print("=" * 60)
print(f"\n📡 Đang kết nối với ESP32 trên {PORT}...")

try:
    ser = serial.Serial(PORT, BAUD, timeout=1)
    print(f"✅ Đã kết nối với {PORT}\n")
    print("🔍 Đang đọc log từ ESP32...")
    print("   Tìm kiếm dấu hiệu Bluetooth đang bật...\n")
    print("-" * 60)
    
    bluetooth_found = False
    wifi_connected = False
    mqtt_connected = False
    
    start_time = time.time()
    
    while True:
        if ser.in_waiting > 0:
            try:
                line = ser.readline().decode('utf-8', errors='ignore').strip()
                
                if line:
                    print(line)
                    
                    # Kiểm tra các dấu hiệu quan trọng
                    if "PROVISIONING MODE" in line or "BLE: Starting advertising" in line:
                        if not bluetooth_found:
                            print("\n" + "=" * 60)
                            print("✅ BLUETOOTH ĐANG BẬT!")
                            print("📱 Tên thiết bị: PROV_thiet_bi_esp32")
                            print("🔵 ESP32 sẵn sàng kết nối qua Bluetooth")
                            print("=" * 60 + "\n")
                            bluetooth_found = True
                    
                    if "WiFi Connected" in line or "Got IP" in line:
                        if not wifi_connected:
                            print("\n" + "=" * 60)
                            print("📶 WIFI ĐÃ KẾT NỐI!")
                            print("=" * 60 + "\n")
                            wifi_connected = True
                    
                    if "MQTT Connected" in line or "MQTT_EVENT_CONNECTED" in line:
                        if not mqtt_connected:
                            print("\n" + "=" * 60)
                            print("☁️ MQTT ĐÃ KẾT NỐI!")
                            print("=" * 60 + "\n")
                            mqtt_connected = True
                    
                    if "WiFi Disconnected" in line:
                        wifi_connected = False
                        mqtt_connected = False
            
            except UnicodeDecodeError:
                pass
        
        # Timeout sau 30 giây nếu không thấy gì
        if time.time() - start_time > 30 and not bluetooth_found and not wifi_connected:
            print("\n⚠️ Không thấy log từ ESP32 sau 30 giây")
            print("💡 Thử:")
            print("   1. Nhấn nút RESET trên ESP32")
            print("   2. Kiểm tra ESP32 có đang cắm đúng cổng COM6 không")
            break
        
        time.sleep(0.1)

except serial.SerialException as e:
    print(f"\n❌ Lỗi kết nối: {e}")
    print("\n💡 Giải pháp:")
    print("   1. Đóng tất cả chương trình đang dùng COM6")
    print("   2. Rút và cắm lại dây USB ESP32")
    print("   3. Kiểm tra Device Manager xem ESP32 có ở COM6 không")
    sys.exit(1)

except KeyboardInterrupt:
    print("\n\n👋 Đã dừng monitor")
    ser.close()
    sys.exit(0)
