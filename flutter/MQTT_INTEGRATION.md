# ✅ Flutter App - MQTT Integration với ESP32

## 🔧 Đã sửa

### 1. **MQTT Broker URL** (`lib/core/app_config.dart`)
```dart
// CŨ (Broker cũ)
return "397cff1b3ee848298abac387ff2829e2.s1.eu.hivemq.cloud";

// MỚI (Khớp với ESP32)
return "cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud";
```

### 2. **MQTT Credentials** (`lib/services/mqtt_service.dart`)
```dart
// CŨ
await client!.connect("nguyenducphat", "Phat123456");

// MỚI (Khớp với ESP32)
await client!.connect("smarthome", "Smarthome123");
```

---

## 📊 Cấu hình MQTT hiện tại

### **ESP32 Firmware**
```c
Broker: mqtts://cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud:8883
Username: smarthome
Password: Smarthome123
```

### **Flutter App**
```dart
Broker: cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud:8883
Username: smarthome
Password: Smarthome123
```

### **Web Dashboard**
```javascript
Broker: wss://cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud:8884/mqtt
Username: smarthome
Password: Smarthome123
```

✅ **Tất cả đã đồng bộ!**

---

## 🎯 MQTT Topics

| Topic | Mô tả | Publisher | Subscriber |
|-------|-------|-----------|------------|
| `smarthome/devices/{hw_id}/set` | Điều khiển thiết bị | Backend, Web, App | ESP32 |
| `smarthome/devices/{hw_id}/state` | Trạng thái thiết bị | ESP32 | Backend, Web, App |
| `smarthome/devices/{hw_id}/sensor` | Dữ liệu cảm biến | ESP32 | Backend, Web, App |

**Ví dụ với `hw_id = "thiet_bi_esp32"`:**
- Control: `smarthome/devices/thiet_bi_esp32/set`
- State: `smarthome/devices/thiet_bi_esp32/state`
- Sensor: `smarthome/devices/thiet_bi_esp32/sensor`

---

## 🔄 Flow hoàn chỉnh

### **1. Thêm thiết bị (QR Code → BLE Provisioning)**
```
App quét QR → Lấy hw_id: "thiet_bi_esp32"
↓
App kết nối BLE với ESP32
↓
App gửi WiFi credentials qua BLE
↓
ESP32 nhận → Lưu WiFi → Restart
↓
ESP32 kết nối WiFi → Kết nối MQTT broker
↓
App gọi API: addDevice(name, hw_id)
↓
Backend lưu device vào database
```

### **2. Điều khiển thiết bị (Toggle ON/OFF)**
```
User toggle switch trong App
↓
App gọi API: toggleDevice(id, isOn)
↓
Backend nhận request
↓
Backend publish MQTT: smarthome/devices/thiet_bi_esp32/set → "ON"
↓
ESP32 subscribe topic → Nhận "ON"
↓
ESP32 bật relay (GPIO 2)
↓
ESP32 publish state: smarthome/devices/thiet_bi_esp32/state → "ON"
↓
App subscribe topic → Nhận "ON" → Update UI
Web subscribe topic → Nhận "ON" → Update UI
```

### **3. Đọc dữ liệu cảm biến (ACS712)**
```
ESP32 đọc ACS712 mỗi 2 giây
↓
ESP32 tính toán: Ampe (A), Watt (W)
↓
ESP32 publish: smarthome/devices/thiet_bi_esp32/sensor → {"A":0.50,"W":110.0}
↓
App/Web subscribe → Nhận dữ liệu → Hiển thị
```

---

## 🧪 Test

### **1. Test MQTT Connection**
Chạy app và xem log:
```
MQTT: Connecting to cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud...
MQTT: ✅ Connected successfully!
MQTT: Subscribed to topic smarthome/devices/+/state
```

### **2. Test Toggle Device**
```
1. Mở app → Toggle switch
2. Xem log:
   📩 MQTT Received: Topic=smarthome/devices/thiet_bi_esp32/state, Payload=ON
   🔄 SYNC: Updating UI for Đèn thông minh -> true
3. Kiểm tra relay trên ESP32 có bật không
```

### **3. Test Sensor Data**
```
1. Mở app → Xem log:
   📩 MQTT Received: Topic=smarthome/devices/thiet_bi_esp32/sensor, Payload={"A":0.50,"W":110.0}
2. Dữ liệu sẽ hiển thị trong app (nếu đã implement UI)
```

---

## ✅ Checklist

- [x] Sửa MQTT broker URL trong Flutter
- [x] Sửa MQTT credentials trong Flutter
- [x] Đồng bộ broker giữa ESP32, Flutter, Web
- [x] Flutter đã có MQTT listener
- [x] Flutter đã có toggle device logic
- [x] Flutter đã có sensor data handling

---

## 🚀 Next Steps

1. **Test thực tế:**
   - Flash ESP32 với firmware mới
   - Chạy Flutter app
   - Quét QR code
   - Cài đặt WiFi qua BLE
   - Toggle device và xem relay có hoạt động không

2. **Hiển thị sensor data:**
   - Thêm UI để hiển thị Ampe, Watt trong app
   - Có thể thêm biểu đồ tiêu thụ điện

3. **Backend integration:**
   - Kiểm tra backend có publish MQTT đúng không
   - Verify backend đang dùng broker nào

---

**Made with ❤️ by Antigravity AI**
