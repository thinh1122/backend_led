# 📱 Cấu hình Flutter App để dùng Docker Local

## 🔄 Thay đổi cần thiết

Sau khi chạy Docker, bạn cần cập nhật file `lib/core/app_config.dart` để app kết nối tới backend local thay vì Render Cloud.

## 📝 Cách 1: Chạy trên Android Emulator

```dart
class AppConfig {
  static String get baseUrl {
    // Android Emulator dùng 10.0.2.2 để truy cập localhost của máy host
    return "http://10.0.2.2:3000/api";
  }
  
  static String get mqttBroker {
    return "10.0.2.2"; // MQTT broker local
  }
  
  static const String appName = "Smart Home IoT";
}
```

Cập nhật MQTT port trong `lib/services/mqtt_service.dart`:
```dart
client!.port = 1883; // Thay vì 8883 (TLS)
client!.secure = false; // Tắt TLS cho local development
```

## 📝 Cách 2: Chạy trên iOS Simulator

```dart
class AppConfig {
  static String get baseUrl {
    return "http://localhost:3000/api";
  }
  
  static String get mqttBroker {
    return "localhost";
  }
  
  static const String appName = "Smart Home IoT";
}
```

## 📝 Cách 3: Chạy trên thiết bị vật lý (Physical Device)

### Bước 1: Tìm IP của máy tính

**Windows:**
```cmd
ipconfig
```
Tìm dòng "IPv4 Address" (thường là 192.168.x.x)

**Mac/Linux:**
```bash
ifconfig
# hoặc
ip addr show
```

### Bước 2: Cập nhật config

```dart
class AppConfig {
  static String get baseUrl {
    // Thay YOUR_LOCAL_IP bằng IP thực của máy (ví dụ: 192.168.1.100)
    return "http://192.168.1.100:3000/api";
  }
  
  static String get mqttBroker {
    return "192.168.1.100";
  }
  
  static const String appName = "Smart Home IoT";
}
```

### Bước 3: Đảm bảo firewall cho phép kết nối

**Windows:**
1. Mở Windows Defender Firewall
2. Advanced Settings → Inbound Rules → New Rule
3. Port → TCP → 3000, 1883, 9001
4. Allow the connection

## 🔧 Cấu hình MQTT Service

Cập nhật file `lib/services/mqtt_service.dart`:

```dart
Future<bool> connect() async {
  String clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
  debugPrint('MQTT: Initializing client $clientId...');
  
  client = MqttServerClient(AppConfig.mqttBroker, clientId);
  
  // ⚠️ QUAN TRỌNG: Thay đổi cho local development
  client!.port = 1883;        // Thay vì 8883
  client!.secure = false;     // Tắt TLS
  
  // Bỏ hoặc comment dòng này vì không dùng TLS
  // client!.onBadCertificate = (dynamic certificate) {
  //     debugPrint('MQTT: ⚠️ Bad Certificate detected but allowed.');
  //     return true; 
  // };
  
  client!.logging(on: true);
  client!.keepAlivePeriod = 60;
  client!.onDisconnected = _onDisconnected;
  client!.onConnected = _onConnected;
  client!.onSubscribed = _onSubscribed;

  final connMess = MqttConnectMessage()
      .withClientIdentifier(clientId)
      .withWillTopic('willtopic')
      .withWillMessage('My Will message')
      .startClean() 
      .withWillQos(MqttQos.atLeastOnce);
  client!.connectionMessage = connMess;

  try {
    debugPrint('MQTT: Connecting to ${AppConfig.mqttBroker}...');
    await client!.connect("smarthome", "Smarthome123"); 
  } catch (e) {
    debugPrint('MQTT: ❌ Exception during connect: $e');
    client!.disconnect();
    return false;
  }

  if (client!.connectionStatus!.state == MqttConnectionState.connected) {
    debugPrint('MQTT: ✅ Connected successfully!');
    return true;
  } else {
    debugPrint('MQTT: ❌ Connection failed - status is ${client!.connectionStatus}');
    client!.disconnect();
    return false;
  }
}
```

## 🧪 Test kết nối

### 1. Kiểm tra Docker containers đang chạy

```bash
docker-compose ps
```

Kết quả mong đợi:
```
NAME                    STATUS              PORTS
smarthome_backend       Up                  0.0.0.0:3000->3000/tcp
smarthome_mongodb       Up                  0.0.0.0:27017->27017/tcp
smarthome_mqtt          Up                  0.0.0.0:1883->1883/tcp, 0.0.0.0:9001->9001/tcp
```

### 2. Test API endpoint

```bash
# Test từ máy host
curl http://localhost:3000/api/health

# Test từ Android Emulator (trong adb shell)
curl http://10.0.2.2:3000/api/health
```

### 3. Test MQTT connection

```bash
# Subscribe
mosquitto_sub -h localhost -p 1883 -u smarthome -P Smarthome123 -t "smarthome/#" -v

# Publish (terminal khác)
mosquitto_pub -h localhost -p 1883 -u smarthome -P Smarthome123 -t "smarthome/test" -m "Hello"
```

## 🔄 Chuyển đổi giữa Local và Cloud

Để dễ dàng chuyển đổi, bạn có thể tạo một flag:

```dart
class AppConfig {
  // Toggle này để chuyển đổi giữa local và cloud
  static const bool useLocalBackend = true; // Đổi thành false để dùng cloud
  
  static String get baseUrl {
    if (useLocalBackend) {
      return "http://10.0.2.2:3000/api"; // Local
    } else {
      return "https://backend-led-xaxn.onrender.com/api"; // Cloud
    }
  }
  
  static String get mqttBroker {
    if (useLocalBackend) {
      return "10.0.2.2"; // Local
    } else {
      return "cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud"; // Cloud
    }
  }
  
  static int get mqttPort {
    return useLocalBackend ? 1883 : 8883;
  }
  
  static bool get mqttSecure {
    return !useLocalBackend; // Local không dùng TLS, Cloud dùng TLS
  }
  
  static const String appName = "Smart Home IoT";
}
```

Sau đó cập nhật `mqtt_service.dart`:
```dart
client!.port = AppConfig.mqttPort;
client!.secure = AppConfig.mqttSecure;

if (AppConfig.mqttSecure) {
  client!.onBadCertificate = (dynamic certificate) {
    debugPrint('MQTT: ⚠️ Bad Certificate detected but allowed.');
    return true; 
  };
}
```

## ⚠️ Lưu ý quan trọng

1. **Android Emulator**: Luôn dùng `10.0.2.2` thay vì `localhost`
2. **iOS Simulator**: Có thể dùng `localhost` trực tiếp
3. **Physical Device**: Phải dùng IP thực của máy và đảm bảo cùng mạng WiFi
4. **Firewall**: Đảm bảo ports 3000, 1883, 9001 được mở
5. **TLS/SSL**: Local development không dùng TLS, cloud thì có

## 🐛 Troubleshooting

### Lỗi: "Failed to connect to /10.0.2.2:3000"
- Kiểm tra Docker containers có chạy không: `docker-compose ps`
- Kiểm tra backend logs: `docker-compose logs backend`

### Lỗi: "MQTT connection failed"
- Kiểm tra Mosquitto có chạy không: `docker-compose logs mosquitto`
- Test MQTT bằng mosquitto_sub/pub
- Đảm bảo username/password đúng

### Lỗi: "Network unreachable" trên physical device
- Kiểm tra máy tính và điện thoại cùng mạng WiFi
- Kiểm tra firewall có block không
- Ping IP của máy từ điện thoại
