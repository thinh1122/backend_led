import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:iot_project/core/app_config.dart';
import 'package:flutter/foundation.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? client;

  Future<bool> connect() async {
    String clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('MQTT: Initializing client $clientId...');
    
    client = MqttServerClient(AppConfig.mqttBroker, clientId);
    client!.port = 8883; 
    client!.secure = true; 
    client!.onBadCertificate = (dynamic certificate) {
        debugPrint('MQTT: ⚠️ Bad Certificate detected but allowed.');
        return true; 
    };
    
    client!.logging(on: true); // Bật Log chi tiết của thư viện MQTT để soi lỗi
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
      // MQTT Credentials - Khớp với ESP32 firmware
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

  void publish(String topic, String message) {
    if (client == null || client!.connectionStatus!.state != MqttConnectionState.connected) {
      debugPrint('MQTT: Cannot publish, not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void subscribe(String topic) {
    if (client == null || client!.connectionStatus!.state != MqttConnectionState.connected) {
       debugPrint('MQTT: Cannot subscribe, not connected');
       return;
    }
    client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  void _onConnected() => debugPrint('MQTT: Client connection was successful');
  void _onDisconnected() => debugPrint('MQTT: Client disconnection was successful');
  void _onSubscribed(String topic) => debugPrint('MQTT: Subscribed to topic $topic');

  Stream<List<MqttReceivedMessage<MqttMessage>>>? get messagesStream => client?.updates;
}
