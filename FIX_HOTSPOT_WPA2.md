# 🔧 HƯỚNG DẪN FIX HOTSPOT ĐỂ ESP32 KẾT NỐI ĐƯỢC

## ❌ Vấn đề hiện tại

ESP32 đang báo lỗi **Reason Code 2** (Authentication Failed) khi kết nối với hotspot "Huy Dat".

**Nguyên nhân:**
- Hotspot đang dùng **WPA3** (ESP32 chỉ hỗ trợ WPA2-PSK)
- Hoặc hotspot có cấu hình đặc biệt không tương thích

---

## ✅ GIẢI PHÁP: Cấu hình Hotspot Android

### **Bước 1: Vào Settings Hotspot**

1. Mở **Settings** trên điện thoại Android
2. Vào **Network & Internet** → **Hotspot & tethering**
3. Hoặc tìm **"Mobile hotspot"** / **"Portable hotspot"**

### **Bước 2: Cấu hình Hotspot**

1. **Bật Mobile hotspot**
2. **Tap vào "Mobile hotspot"** (không phải toggle switch) để vào cấu hình chi tiết
3. Hoặc tap vào **"Set up Wi‑Fi hotspot"** / **"Configure"**

### **Bước 3: Đặt cấu hình**

**Tên mạng (SSID):**
- Đặt tên đơn giản: `ESP32_Test` hoặc `TestWiFi`
- **KHÔNG dùng dấu cách, ký tự đặc biệt**

**Security:**
- Chọn **WPA2-PSK** (QUAN TRỌNG!)
- **KHÔNG chọn WPA3** hoặc **WPA2/WPA3 Mixed**

**Password:**
- Đặt mật khẩu đơn giản: `12345678` hoặc `password123`
- **KHÔNG dùng ký tự đặc biệt phức tạp**

**Band:**
- Chọn **2.4 GHz** (ESP32-C3 chỉ hỗ trợ 2.4GHz)
- **KHÔNG chọn 5 GHz** hoặc **Auto**

### **Bước 4: Lưu và bật lại**

1. **Save** / **Lưu** cấu hình
2. **Tắt** hotspot (nếu đang bật)
3. **Bật lại** hotspot với cấu hình mới

---

## ⚠️ LƯU Ý VỚI iOS HOTSPOT

**iOS hotspot có thể tự động dùng WPA3**, và **KHÔNG có tùy chọn để đổi sang WPA2**.

### **Giải pháp:**

1. **Dùng Android hotspot thay vì iOS** (Khuyến nghị)
2. Hoặc thử các cách sau với iOS:

#### **Cách 1: Reset Network Settings**
- Settings → General → Transfer or Reset iPhone → Reset → Reset Network Settings
- Sau đó bật lại hotspot

#### **Cách 2: Dùng iPhone cũ hơn**
- iPhone cũ hơn iOS 13 có thể dùng WPA2 mặc định

#### **Cách 3: Dùng USB Tethering**
- Cắm iPhone vào máy tính
- Bật USB Tethering
- Máy tính sẽ share WiFi cho ESP32

---

## 🧪 TEST SAU KHI CẤU HÌNH

### **1. Kiểm tra cấu hình hotspot:**

Trên điện thoại Android, vào lại Settings → Hotspot và kiểm tra:
- ✅ Security: **WPA2-PSK** (không phải WPA3)
- ✅ Band: **2.4 GHz** (không phải 5GHz)
- ✅ SSID: Tên đơn giản, không dấu

### **2. Cấu hình lại ESP32:**

1. Mở app Flutter
2. Vào BLE Provisioning
3. Chọn WiFi mới (`ESP32_Test`)
4. Nhập password mới (`12345678`)
5. Chọn phòng → Hoàn tất

### **3. Xem log ESP32:**

Sau khi restart, bạn sẽ thấy:

**✅ Thành công:**
```
✅ WiFi Connected Successfully!
   SSID: ESP32_Test
⏳ Waiting for IP address...
🌐 IP Address Obtained!
   IP: 192.168.43.XXX
🚀 Starting MQTT connection...
MQTT Connected
```

**❌ Vẫn lỗi:**
```
❌ WiFi Disconnected!
   Reason Code: 2
⚠️ AUTHENTICATION FAILED
```

→ Nếu vẫn lỗi, thử hotspot Android khác hoặc kiểm tra lại cấu hình.

---

## 📱 HƯỚNG DẪN THEO TỪNG HÃNG ĐIỆN THOẠI

### **Samsung Galaxy:**

1. Settings → Connections → Mobile hotspot and tethering
2. Mobile hotspot → **Configure** (icon bánh răng)
3. Security: Chọn **WPA2-PSK**
4. Band: Chọn **2.4 GHz**
5. Save

### **Xiaomi/Redmi:**

1. Settings → Personal hotspot
2. Tap vào **"Set up Wi‑Fi hotspot"**
3. Security: Chọn **WPA2-PSK**
4. Band: Chọn **2.4 GHz**
5. Save

### **OPPO/Realme:**

1. Settings → Other wireless connections → Personal hotspot
2. Tap vào **"Set up Wi‑Fi hotspot"**
3. Security: Chọn **WPA2-PSK**
4. Band: Chọn **2.4 GHz**
5. Save

### **Huawei:**

1. Settings → Wireless & networks → More → Tethering & portable hotspot
2. Portable Wi‑Fi hotspot → **Configure Wi‑Fi hotspot**
3. Security: Chọn **WPA2-PSK**
4. Band: Chọn **2.4 GHz**
5. Save

---

## 🔍 KIỂM TRA HOTSPOT ĐANG DÙNG GÌ

### **Cách 1: Xem trên điện thoại khác**

1. Kết nối điện thoại khác với hotspot
2. Vào Settings → WiFi
3. Tap vào hotspot đang kết nối
4. Xem **Security type**: Phải là **WPA2** (không phải WPA3)

### **Cách 2: Dùng app WiFi Analyzer**

1. Tải app **WiFi Analyzer** trên Android
2. Quét WiFi networks
3. Tìm hotspot của bạn
4. Xem **Security**: Phải là **WPA2**

---

## 💡 TIPS

1. **Luôn dùng Android hotspot** thay vì iOS (dễ cấu hình WPA2 hơn)
2. **Đặt tên SSID đơn giản**: Không dấu, không ký tự đặc biệt
3. **Mật khẩu đơn giản**: `12345678` hoặc `password123`
4. **Chỉ dùng 2.4 GHz**: ESP32-C3 không hỗ trợ 5GHz
5. **Tắt hotspot và bật lại** sau khi đổi cấu hình

---

## 🎯 KẾT QUẢ MONG ĐỢI

Sau khi cấu hình đúng, ESP32 sẽ:

1. ✅ Kết nối WiFi thành công
2. ✅ Nhận IP từ hotspot
3. ✅ Kết nối MQTT broker
4. ✅ Sẵn sàng nhận lệnh điều khiển từ app

---

**Nếu vẫn không được, hãy thử hotspot Android khác hoặc gửi log ESP32 mới nhất!**
