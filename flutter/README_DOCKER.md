# 🐳 Docker Setup cho Smart Home IoT

## 📋 Yêu cầu

- Docker Desktop (Windows/Mac) hoặc Docker Engine (Linux)
- Docker Compose v2.0+

## 🚀 Cài đặt và chạy

### 1. Tạo MQTT password file

```bash
# Tạo thư mục nếu chưa có
mkdir -p mosquitto/config

# Tạo user và password cho MQTT
docker run -it --rm -v ${PWD}/mosquitto/config:/mosquitto/config eclipse-mosquitto:2.0 mosquitto_passwd -c /mosquitto/config/passwd smarthome
# Nhập password: Smarthome123
```

**Trên Windows PowerShell:**
```powershell
# Tạo thư mục
New-Item -ItemType Directory -Force -Path mosquitto\config

# Tạo password file
docker run -it --rm -v ${PWD}/mosquitto/config:/mosquitto/config eclipse-mosquitto:2.0 mosquitto_passwd -c /mosquitto/config/passwd smarthome
# Nhập password: Smarthome123
```

### 2. Khởi động Docker containers

```bash
docker-compose up -d
```

### 3. Kiểm tra containers đang chạy

```bash
docker-compose ps
```

Bạn sẽ thấy 3 containers:
- `smarthome_mongodb` - MongoDB database (port 27017)
- `smarthome_mqtt` - Mosquitto MQTT broker (ports 1883, 9001)
- `smarthome_backend` - Backend API (port 3000)

### 4. Xem logs

```bash
# Xem tất cả logs
docker-compose logs -f

# Xem log của một service cụ thể
docker-compose logs -f backend
docker-compose logs -f mosquitto
docker-compose logs -f mongodb
```

## 🔧 Cấu hình Flutter App

Sau khi Docker chạy, cập nhật file `lib/core/app_config.dart`:

```dart
class AppConfig {
  static String get baseUrl {
    // Thay đổi từ Render Cloud sang localhost
    return "http://10.0.2.2:3000/api"; // Android Emulator
    // return "http://localhost:3000/api"; // iOS Simulator
    // return "http://YOUR_LOCAL_IP:3000/api"; // Physical device
  }
  
  static String get mqttBroker {
    // Thay đổi từ HiveMQ Cloud sang localhost
    return "10.0.2.2"; // Android Emulator
    // return "localhost"; // iOS Simulator
    // return "YOUR_LOCAL_IP"; // Physical device
  }
  
  static const String appName = "Smart Home IoT";
}
```

**Lưu ý về địa chỉ IP:**
- `10.0.2.2` - Địa chỉ đặc biệt của Android Emulator để truy cập localhost của máy host
- `localhost` - Dùng cho iOS Simulator
- `192.168.x.x` - IP thực của máy (dùng cho thiết bị vật lý)

Để tìm IP của máy:
```bash
# Windows
ipconfig

# Mac/Linux
ifconfig
```

## 📊 Services và Ports

| Service | Port | Mô tả |
|---------|------|-------|
| Backend API | 3000 | REST API endpoint |
| MongoDB | 27017 | Database |
| MQTT (TCP) | 1883 | MQTT protocol |
| MQTT (WebSocket) | 9001 | MQTT over WebSocket |

## 🧪 Test MQTT Connection

### Sử dụng MQTT CLI (mosquitto_pub/sub)

**Subscribe:**
```bash
mosquitto_sub -h localhost -p 1883 -u smarthome -P Smarthome123 -t "smarthome/devices/+/state" -v
```

**Publish:**
```bash
mosquitto_pub -h localhost -p 1883 -u smarthome -P Smarthome123 -t "smarthome/devices/test/set" -m "ON"
```

### Sử dụng MQTT Explorer (GUI)

1. Tải MQTT Explorer: http://mqtt-explorer.com/
2. Kết nối với:
   - Host: `localhost`
   - Port: `1883`
   - Username: `smarthome`
   - Password: `Smarthome123`

## 🛠️ Quản lý Docker

### Dừng containers
```bash
docker-compose stop
```

### Khởi động lại
```bash
docker-compose start
```

### Xóa containers (giữ data)
```bash
docker-compose down
```

### Xóa containers và data
```bash
docker-compose down -v
```

### Rebuild containers
```bash
docker-compose up -d --build
```

## 📁 Cấu trúc thư mục

```
.
├── docker-compose.yml          # Docker Compose configuration
├── .env.example               # Environment variables template
├── mosquitto/
│   ├── config/
│   │   ├── mosquitto.conf    # MQTT broker config
│   │   └── passwd            # MQTT users (tạo bằng mosquitto_passwd)
│   ├── data/                 # MQTT persistence data
│   └── log/                  # MQTT logs
└── backend/                   # Backend source code (cần tạo)
    ├── package.json
    ├── src/
    └── ...
```

## ⚠️ Lưu ý

1. **Backend code**: Docker setup này giả định bạn có backend code trong thư mục `backend/`. Nếu chưa có, bạn cần tạo backend API.

2. **MQTT Password**: File `mosquitto/config/passwd` chứa mật khẩu đã mã hóa. Không commit file này vào Git.

3. **Security**: Cấu hình này dùng cho development. Với production, cần:
   - Thay đổi passwords
   - Bật TLS/SSL cho MQTT
   - Sử dụng environment variables
   - Cấu hình firewall

4. **Network**: Tất cả services chạy trong cùng Docker network `smarthome_network` để có thể giao tiếp với nhau.

## 🐛 Troubleshooting

### Container không start
```bash
# Xem logs chi tiết
docker-compose logs backend
docker-compose logs mosquitto
```

### Không kết nối được MQTT
```bash
# Kiểm tra MQTT broker có chạy không
docker-compose exec mosquitto mosquitto -h

# Test connection
docker-compose exec mosquitto mosquitto_sub -h localhost -p 1883 -u smarthome -P Smarthome123 -t test
```

### Backend không kết nối được MongoDB
```bash
# Kiểm tra MongoDB
docker-compose exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin
```

## 📚 Tài liệu tham khảo

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Mosquitto Documentation](https://mosquitto.org/documentation/)
- [MongoDB Docker Hub](https://hub.docker.com/_/mongo)
