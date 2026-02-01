# HƯỚNG DẪN KIỂM TRA ESP32 BLUETOOTH

## Cách 1: Dùng Python Script (Đơn giản nhất)

```bash
cd Relay
python check_esp_status.py
```

**Kết quả mong đợi:**
```
✅ BLUETOOTH ĐANG BẬT!
📱 Tên thiết bị: PROV_thiet_bi_esp32
🔵 ESP32 sẵn sàng kết nối qua Bluetooth
```

---

## Cách 2: Dùng ESP-IDF Monitor

```bash
cd Relay
check_bluetooth.bat
```

---

## Cách 3: Nhìn đèn LED trên ESP32

### ESP32 ĐANG BẬT BLUETOOTH (Chưa có WiFi):
- ❌ **KHÔNG có WiFi** → Bluetooth tự động bật
- 🔵 **Đèn LED nhấp nháy chậm** (nếu có)
- 📱 **Có thể quét được** tên `PROV_thiet_bi_esp32` trên app

### ESP32 ĐÃ KẾT NỐI WIFI:
- ✅ **Đã có WiFi** → Bluetooth tự động TẮT
- 🟢 **Đèn LED sáng liên tục** hoặc nhấp nháy nhanh
- ☁️ **Kết nối MQTT** để điều khiển từ xa

---

## Các dấu hiệu trong LOG:

### ✅ Bluetooth ĐANG BẬT:
```
I (582) SMART_PLUG: =============================================
I (592) SMART_PLUG: 📶 DEVICE IN PROVISIONING MODE (SETUP)
I (502) SMART_PLUG: 📱 Please open the Mobile App to configure WiFi
I (592) SMART_PLUG: BLE: Starting advertising as PROV_thiet_bi_esp32...
```

### ✅ WiFi ĐÃ KẾT NỐI:
```
I (5432) SMART_PLUG: ✅ WiFi Connected!
I (5442) SMART_PLUG:    📶 SSID: OPPO
I (5452) SMART_PLUG:    📡 IP Address: 192.168.x.x
```

### ✅ MQTT ĐÃ KẾT NỐI:
```
I (8234) SMART_PLUG: ✅ MQTT Connected to HiveMQ Cloud!
I (8244) SMART_PLUG: 📡 Device is ready for remote control
```

---

## Cách RESET để bật lại Bluetooth:

### Nếu ESP32 đã có WiFi và bạn muốn kết nối Bluetooth lại:

**Cách 1: Xóa WiFi bằng MQTT**
```bash
cd Relay
python test_mqtt_quick.py
# Gửi lệnh: RESET_WIFI
```

**Cách 2: Xóa WiFi bằng script**
```bash
cd Relay
python reset_esp32_wifi.py
```

**Cách 3: Xóa toàn bộ flash**
```bash
cd Relay
erase_and_flash.bat
```

Sau khi xóa WiFi, ESP32 sẽ tự động bật lại Bluetooth!

---

## Troubleshooting:

### ❌ Không thấy log gì:
1. Nhấn nút **RESET** trên ESP32
2. Rút và cắm lại dây USB
3. Kiểm tra Device Manager → ESP32 có ở COM6 không

### ❌ Không quét được Bluetooth trên app:
1. Kiểm tra ESP32 có đang ở chế độ Provisioning không (xem log)
2. Đảm bảo ESP32 **CHƯA** kết nối WiFi
3. Bật Bluetooth trên điện thoại
4. Cho phép quyền Bluetooth cho app

### ❌ ESP32 đã có WiFi, muốn kết nối Bluetooth lại:
- Xóa WiFi bằng một trong 3 cách trên
- ESP32 sẽ tự động chuyển sang chế độ Bluetooth

---

## Tóm tắt:

| Trạng thái | Bluetooth | WiFi | MQTT | Cách điều khiển |
|------------|-----------|------|------|-----------------|
| **Provisioning** | ✅ BẬT | ❌ TẮT | ❌ TẮT | Qua app Bluetooth |
| **Connected** | ❌ TẮT | ✅ BẬT | ✅ BẬT | Qua MQTT cloud |

**Lưu ý:** ESP32 chỉ bật Bluetooth khi **CHƯA có WiFi**!
