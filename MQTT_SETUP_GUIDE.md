# 🚀 Hướng dẫn Setup MQTT cho Smart Home App

## ✅ Đã cập nhật Broker URL mới

**Broker cũ:** `14baa3968cc940f9862d88e92ef01c3d.s1.eu.hivemq.cloud`  
**Broker mới:** `cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud`

---

## 📊 Cấu hình MQTT hiện tại

### **HiveMQ Cloud Credentials**
```
Broker: cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud
Username: smarthome
Password: Smarthome123
```

### **Ports**
- **MQTT over TLS (ESP32, Backend):** `8883`
- **WebSocket (Web Dashboard):** `8884`

### **MQTT Topics**
| Topic | Mô tả | Publisher | Subscriber |
|-------|-------|-----------|------------|
| `smarthome/devices/{hw_id}/set` | Điều khiển thiết bị | Backend, Web, App | ESP32 |
| `smarthome/devices/{hw_id}/state` | Trạng thái thiết bị | ESP32 | Backend, Web, App |
| `smarthome/devices/{hw_id}/sensor` | Dữ liệu cảm biến | ESP32 | Backend, Web, App |

---

## 🔧 Setup từng component

### **1. Backend Java (Spring Boot)**

**File đã cập nhật:** `backend_led/src/main/java/com/nguyenducphat/backend_led/config/MqttConfig.java`

```bash
cd smart_home_app/backend_led

# Khởi động Database
docker-compose up -d db

# Chạy Backend
mvnw.cmd spring-boot:run
```

**Kiểm tra log:**
```
Connected to MQTT broker: ssl://cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud:8883
Subscribed to: smarthome/devices/+/state
```

---

### **2. ESP32 Firmware**

**File đã cập nhật:** `Relay/main/blink_example_main.c`

**Cách flash:**
```bash
cd smart_home_app/Relay

# Build firmware
idf.py build

# Flash vào ESP32
idf.py -p COM3 flash monitor
```

**Kiểm tra log:**
```
MQTT Connected
📡 Subscribed to: smarthome/devices/+/set
```

---

### **3. Flutter App**

**File đã cập nhật:** `flutter/lib/core/app_config.dart`

```bash
cd smart_home_app/flutter

# Cài dependencies
flutter pub get

# Chạy app
flutter run
```

**Kiểm tra log:**
```
MQTT: Connecting to cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud...
MQTT: ✅ Connected successfully!
```

---

### **4. Web Dashboard**

**File đã cập nhật:** `web/src/services/mqttService.js`

```bash
cd smart_home_app/web

# Cài dependencies
npm install

# Chạy dev server
npm run dev
```

**Kiểm tra console:**
```
✅ MQTT Connected to ESP32 Broker
📡 Subscribed to device state updates
```

---

## 🧪 Test MQTT Connection

### **Option 1: Dùng MQTT Explorer (Recommended)**

1. Download: https://mqtt-explorer.com/
2. Kết nối với:
   - Host: `cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud`
   - Port: `8883`
   - Protocol: `mqtts://`
   - Username: `smarthome`
   - Password: `Smarthome123`

3. Subscribe topic: `smarthome/devices/#`
4. Publish test message:
   - Topic: `smarthome/devices/thiet_bi_esp32/set`
   - Payload: `ON`

---

### **Option 2: Dùng mosquitto_pub/sub**

**Subscribe (Terminal 1):**
```bash
mosquitto_sub -h cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud -p 8883 -t "smarthome/devices/#" -u smarthome -P Smarthome123 --capath /etc/ssl/certs/
```

**Publish (Terminal 2):**
```bash
mosquitto_pub -h cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud -p 8883 -t "smarthome/devices/thiet_bi_esp32/set" -m "ON" -u smarthome -P Smarthome123 --capath /etc/ssl/certs/
```

---

## 🔄 Flow hoàn chỉnh

### **Điều khiển thiết bị (Toggle ON/OFF)**
```
User toggle switch trong App
↓
App gọi API: toggleDevice(id, isOn)
↓
Backend publish MQTT: smarthome/devices/thiet_bi_esp32/set → "ON"
↓
ESP32 subscribe topic → Nhận "ON" → Bật relay
↓
ESP32 publish state: smarthome/devices/thiet_bi_esp32/state → "ON"
↓
App/Web subscribe → Nhận "ON" → Update UI
```

### **Đọc dữ liệu cảm biến**
```
ESP32 đọc ACS712 mỗi 2 giây
↓
ESP32 publish: smarthome/devices/thiet_bi_esp32/sensor → {"A":0.50,"W":110.0}
↓
App/Web subscribe → Nhận dữ liệu → Hiển thị
```

---

## ✅ Checklist

- [x] Backend Java: Đã cập nhật broker URL
- [x] ESP32 Firmware: Đã cập nhật broker URL
- [x] Flutter App: Đã cập nhật broker URL
- [x] Web Dashboard: Đã cập nhật broker URL
- [x] MQTT Topics: Đã đồng bộ
- [x] Credentials: Đã đồng bộ

---

## 🚨 Troubleshooting

### **Lỗi: Connection refused**
- Kiểm tra username/password đúng chưa
- Kiểm tra port: 8883 (MQTT), 8884 (WebSocket)
- Kiểm tra firewall có block không

### **Lỗi: Certificate verify failed**
- Backend/ESP32: Đảm bảo dùng `ssl://` hoặc `mqtts://`
- Web: Đảm bảo dùng `wss://`

### **Lỗi: MQTT not connected**
- Kiểm tra internet connection
- Kiểm tra HiveMQ Cloud account còn active không
- Xem log để biết lỗi cụ thể

---

## 📝 Notes

- **HiveMQ Cloud Free Tier:** 
  - Max 100 connections
  - Max 10 GB data transfer/month
  - Nếu vượt quota, cần upgrade plan

- **Mosquitto Local (Dự phòng):**
  - Nếu muốn dùng Mosquitto local, uncomment code trong `MqttConfig.java`
  - Chạy: `docker-compose up -d mqtt`

---

**Made with ❤️ by Kiro AI**
