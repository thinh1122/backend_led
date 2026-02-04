# 🎤 HƯỚNG DẪN TEST VOICE CONTROL

## Các lệnh giọng nói được hỗ trợ:

### 1. **"BẬT"** - Bật thiết bị
- Nói rõ ràng: "BẬT"
- Hoặc: "TURN ON"
- LED sẽ sáng, relay bật

### 2. **"TẮT"** - Tắt thiết bị  
- Nói rõ ràng: "TẮT"
- Hoặc: "TURN OFF"
- LED tắt, relay tắt

## Cách test:

### Bước 1: Kiểm tra kết nối
```
1. Flash code với build_with_voice.bat
2. Mở Serial Monitor (115200 baud)
3. Kiểm tra log: "✅ Voice Control started successfully"
```

### Bước 2: Test microphone
```
1. Nói to gần mic (cách 10-20cm)
2. Xem log: "🎤 Voice activity detected!"
3. Nếu không có → Kiểm tra kết nối phần cứng
```

### Bước 3: Test commands
```
1. Nói "BẬT" → Xem log: "🎤 Detected: TURN ON command"
2. Nói "TẮT" → Xem log: "🎤 Detected: TURN OFF command"
3. Relay phải thay đổi trạng thái
```

## Troubleshooting:

### Lỗi "Failed to start Voice Control":
- Kiểm tra kết nối GPIO4, GPIO5, GPIO6
- Kiểm tra nguồn 3.3V cho INMP441

### Không detect được giọng nói:
- Tăng âm lượng nói
- Kiểm tra L/R pin nối GND
- Thử nói gần mic hơn (5-10cm)

### Detect sai lệnh:
- Nói rõ ràng, chậm rãi
- Tránh tiếng ồn xung quanh
- Code hiện tại dùng thuật toán đơn giản, có thể cần fine-tune

## Nâng cấp trong tương lai:

1. **Thêm nhiều lệnh hơn:**
   - "SÁNG HƠN" / "TỐI HƠN" (dimmer)
   - "HẸN GIỜ 5 PHÚT"
   - "TRẠNG THÁI"

2. **Cải thiện độ chính xác:**
   - Sử dụng AI/ML models
   - Edge Impulse integration
   - Wake word detection

3. **Thêm feedback âm thanh:**
   - Speaker để phản hồi
   - "Đã bật", "Đã tắt"