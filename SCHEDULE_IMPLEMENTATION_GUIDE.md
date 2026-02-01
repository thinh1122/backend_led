# 📅 HƯỚNG DẪN TRIỂN KHAI TÍNH NĂNG HẸN GIỜ

## ✅ ĐÃ HOÀN THÀNH

### 🎯 BACKEND (Spring Boot)

#### 1. **SchedulerTaskService.java** ✅
- Tự động chạy mỗi phút (cron: `0 * * * * *`)
- Kiểm tra tất cả lịch hẹn đang bật
- So sánh thời gian hiện tại với thời gian hẹn
- Kiểm tra ngày lặp lại (1=CN, 2=T2, ..., 7=T7)
- Gửi lệnh MQTT khi đến giờ

#### 2. **MqttService.java** ✅
- Kết nối HiveMQ Cloud
- Gửi lệnh ON/OFF qua MQTT
- Auto-reconnect khi mất kết nối
- QoS 1 (At least once delivery)

#### 3. **Dependencies** ✅
- Thêm `org.eclipse.paho.client.mqttv3` vào `pom.xml`
- Enable `@EnableScheduling` trong `BackendLedApplication.java`

#### 4. **Repository** ✅
- Thêm method `findByEnabled(Boolean enabled)` vào `ScheduleRepository`

---

## 🚀 CÁCH HOẠT ĐỘNG

### **Flow tổng thể:**

```
1. User tạo lịch hẹn trên App
   ↓
2. App gửi API POST /api/schedules
   ↓
3. Backend lưu vào database
   ↓
4. SchedulerTaskService chạy mỗi phút
   ↓
5. Kiểm tra: Giờ hiện tại == Giờ hẹn?
   ↓
6. Nếu đúng → Gửi MQTT: smarthome/devices/thiet_bi_esp32/set → "ON"/"OFF"
   ↓
7. ESP32 nhận MQTT → Bật/tắt relay
```

---

## 📋 ESP32 - KHÔNG CẦN SỬA CODE!

**Lý do:** ESP32 đã có sẵn code nhận MQTT và điều khiển relay!

### **Code hiện tại đã đủ:**

```c
// ESP32 đã subscribe topic: smarthome/devices/thiet_bi_esp32/set
// Khi nhận "ON" → Bật relay
// Khi nhận "OFF" → Tắt relay
```

**Backend sẽ tự động gửi lệnh MQTT khi đến giờ hẹn!**

---

## 🧪 CÁCH TEST

### **Bước 1: Build và chạy backend**

```bash
cd backend_led
mvn clean package
docker-compose up --build
```

### **Bước 2: Tạo lịch hẹn qua API**

```bash
curl -X POST http://localhost:8080/api/schedules \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "deviceId": 1,
    "time": "14:30",
    "action": "ON",
    "enabled": true,
    "repeatDays": "1,2,3,4,5,6,7",
    "name": "Bật đèn lúc 2:30 PM"
  }'
```

### **Bước 3: Đợi đến giờ hẹn**

- Backend sẽ tự động gửi MQTT lúc 14:30
- ESP32 sẽ nhận và bật relay
- Check log backend:
  ```
  🚀 Executing schedule: Bật đèn lúc 2:30 PM - Device: thiet_bi_esp32 - Action: ON
  ✅ Schedule executed successfully: Bật đèn lúc 2:30 PM
  ```

### **Bước 4: Test trên App**

1. Mở app → Vào chi tiết thiết bị
2. Chọn tab "Hẹn giờ"
3. Bấm "Thêm lịch hẹn"
4. Chọn giờ, action (ON/OFF), tên
5. Lưu
6. Đợi đến giờ → Thiết bị tự động bật/tắt!

---

## 🔧 CẤU HÌNH MQTT (application.properties)

Thêm vào `backend_led/src/main/resources/application.properties`:

```properties
# MQTT Configuration
mqtt.broker=ssl://cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud:8883
mqtt.username=smarthome
mqtt.password=Smarthome123
mqtt.client-id=backend-scheduler
```

---

## 📊 DATABASE SCHEMA

Table `schedules` đã có sẵn:

```sql
CREATE TABLE schedules (
    id BIGSERIAL PRIMARY KEY,
    device_id BIGINT NOT NULL REFERENCES devices(id),
    time TIME NOT NULL,
    action VARCHAR(10) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true,
    repeat_days VARCHAR(50) NOT NULL DEFAULT '1,2,3,4,5,6,7',
    name VARCHAR(255)
);
```

---

## 🎯 TÍNH NĂNG

### ✅ Đã có:
- [x] Hẹn giờ bật/tắt theo giờ cụ thể
- [x] Lặp lại theo ngày (CN, T2-T7)
- [x] Bật/tắt lịch hẹn
- [x] Đặt tên lịch hẹn
- [x] Tự động gửi MQTT khi đến giờ
- [x] UI Flutter hoàn chỉnh

### 🔮 Có thể mở rộng:
- [ ] Đếm ngược (Tắt sau 30 phút)
- [ ] Sunrise/Sunset (Bật khi trời tối)
- [ ] Automation (Nếu nhiệt độ > 30°C thì bật)
- [ ] Thông báo push khi thực thi lịch hẹn

---

## 🐛 TROUBLESHOOTING

### **Lỗi: MQTT không kết nối**
```
❌ MQTT Connection failed: Connection refused
```
**Giải pháp:**
- Kiểm tra firewall có chặn port 8883 không
- Kiểm tra username/password đúng chưa
- Kiểm tra Internet có hoạt động không

### **Lỗi: Lịch hẹn không chạy**
```
⏰ Checking schedules at 14:30 (Day: 2)
```
**Giải pháp:**
- Kiểm tra `enabled = true`
- Kiểm tra `repeatDays` có chứa ngày hiện tại không
- Kiểm tra timezone backend đúng chưa (GMT+7)

### **Lỗi: ESP32 không nhận MQTT**
```
W (1114251) mqtt_client: Error transport connect
```
**Giải pháp:**
- Kiểm tra ESP32 có kết nối WiFi không
- Kiểm tra WiFi có chặn port 8883 không
- Thử đổi sang WiFi khác (iPhone hotspot)

---

## 📝 NOTES

1. **Timezone:** Backend mặc định dùng timezone của server. Nếu cần GMT+7, thêm vào `application.properties`:
   ```properties
   spring.jpa.properties.hibernate.jdbc.time_zone=Asia/Ho_Chi_Minh
   ```

2. **Cron Expression:** `0 * * * * *` = Chạy mỗi phút (giây 0)
   - Nếu muốn chạy mỗi 30 giây: `0,30 * * * * *`
   - Nếu muốn chạy mỗi 5 phút: `0 */5 * * * *`

3. **QoS Level:** Đang dùng QoS 1 (At least once)
   - QoS 0: Fire and forget (nhanh nhưng có thể mất)
   - QoS 1: At least once (chậm hơn nhưng đảm bảo)
   - QoS 2: Exactly once (chậm nhất, đảm bảo tuyệt đối)

---

## 🎉 KẾT LUẬN

**Tính năng hẹn giờ đã HOÀN THÀNH 100%!**

- ✅ Backend tự động kiểm tra và gửi MQTT
- ✅ ESP32 nhận và thực thi (không cần sửa code)
- ✅ App có UI đầy đủ
- ✅ Database đã có schema

**Chỉ cần build và chạy backend là xong!**

```bash
cd backend_led
mvn clean package
docker-compose up --build
```

Sau đó test bằng cách tạo lịch hẹn trên app và đợi đến giờ! 🚀
