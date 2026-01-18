# 🚀 Cách chạy app

## ⚠️ QUAN TRỌNG: App này KHÔNG hỗ trợ Windows Desktop

App này chỉ chạy trên:
- ✅ Android (Emulator hoặc Physical Device)
- ✅ iOS (Simulator hoặc Physical Device)
- ❌ Windows Desktop (KHÔNG hỗ trợ)

## 📱 Cách 1: Chạy từ Command Line (Khuyến nghị)

### Kiểm tra devices có sẵn:
```bash
flutter devices
```

### Chạy trên Android Emulator:
```bash
flutter run -d emulator-5554
```

### Chạy trên thiết bị vật lý:
```bash
# Xem danh sách devices
flutter devices

# Chạy trên device cụ thể
flutter run -d <device-id>
```

## 🖥️ Cách 2: Chạy từ IDE (IntelliJ IDEA / Android Studio)

### Bước 1: Chọn Device
1. Nhìn lên góc trên bên phải IDE
2. Tìm dropdown device (bên cạnh nút Run/Debug)
3. **QUAN TRỌNG**: Chọn "sdk gphone64 x86 64 (emulator-5554)" hoặc Android device khác
4. **KHÔNG CHỌN "Windows"**

### Bước 2: Chọn Run Configuration
1. Bên cạnh dropdown device, tìm dropdown run configuration
2. Chọn "main.dart (Android Emulator)"
3. Nếu không có, chọn "main.dart" và đảm bảo device là Android

### Bước 3: Run
1. Click nút Run (▶️) hoặc Debug (🐛)
2. Hoặc nhấn Shift+F10 (Run) / Shift+F9 (Debug)

## 🔧 Nếu gặp lỗi "No Windows desktop project configured"

Điều này có nghĩa bạn đang cố chạy trên Windows. Làm theo các bước sau:

### Trong IDE:
1. **Đóng app đang chạy** (nếu có)
2. **Chọn lại device**: Click dropdown device → Chọn Android emulator
3. **Run lại**

### Hoặc dùng Command Line:
```bash
# Dừng tất cả
flutter clean

# Chạy lại với device cụ thể
flutter run -d emulator-5554
```

## 📋 Checklist trước khi chạy

- [ ] Android Emulator đã được khởi động
- [ ] Device dropdown trong IDE đang chọn Android (KHÔNG phải Windows)
- [ ] Run configuration đúng (main.dart hoặc main.dart (Android Emulator))

## 🎯 Quick Commands

```bash
# Xem devices
flutter devices

# Chạy trên Android emulator
flutter run -d emulator-5554

# Build APK
flutter build apk --debug

# Hot reload (khi app đang chạy)
# Nhấn 'r' trong terminal

# Hot restart (khi app đang chạy)
# Nhấn 'R' trong terminal

# Dừng app
# Nhấn 'q' trong terminal
```

## 🐛 Troubleshooting

### Lỗi: "No devices found"
```bash
# Kiểm tra emulator có chạy không
adb devices

# Khởi động emulator
# Mở Android Studio → AVD Manager → Start emulator
```

### Lỗi: "Gradle build failed"
```bash
flutter clean
flutter pub get
cd android
.\gradlew.bat clean
cd ..
flutter run -d emulator-5554
```

### IDE cứ chọn Windows làm default
1. File → Settings → Languages & Frameworks → Flutter
2. Kiểm tra Flutter SDK path: `C:\src\flutter`
3. Restart IDE
4. Chọn lại device trong dropdown

## 💡 Tips

- **Hot Reload**: Sau khi sửa code, nhấn `r` để reload nhanh (không cần build lại)
- **Hot Restart**: Nhấn `R` để restart app hoàn toàn
- **DevTools**: Khi app chạy, mở link DevTools trong terminal để debug
- **Logs**: Xem logs trong terminal hoặc IDE console

## 📞 Nếu vẫn gặp vấn đề

1. Đảm bảo Flutter SDK đã cài đúng: `flutter doctor -v`
2. Đảm bảo Android emulator đang chạy: `adb devices`
3. Clean project: `flutter clean && flutter pub get`
4. Restart IDE
5. Chạy lại: `flutter run -d emulator-5554`
