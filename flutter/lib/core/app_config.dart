

class AppConfig {
  static String get baseUrl {
    // API Render Cloud (NEW - Updated 2025-02-01)
    return "https://backend-ed-d5nvgqogph6c08r8u4c0.onrender.com/api";
    
    // Local Docker Backend (uncomment nếu muốn dùng local)
    // return "http://192.168.1.28:8080/api";
  }
  static String get mqttBroker {
    // HiveMQ Cloud Broker
    return "cff511b394b84e8e9bba66c541c0fde3.s1.eu.hivemq.cloud"; 
  }
  
  static const String appName = "Smart Home IoT";
}
