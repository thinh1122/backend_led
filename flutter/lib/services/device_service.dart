
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const String _storageKey = 'added_devices';

  // Thêm một thiết bị mới
  static Future<void> addDevice(String name, String image, {String type = 'Wi-Fi'}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? devicesJson = prefs.getString(_storageKey);
    
    List<dynamic> devices = [];
    if (devicesJson != null) {
      devices = jsonDecode(devicesJson);
    }

    // Kiểm tra xem đã có chưa (optional)
    devices.add({
      'name': name,
      'image': image,
      'type': type,
      'isOn': false,
    });

    await prefs.setString(_storageKey, jsonEncode(devices));
  }

  // Lấy danh sách thiết bị đã thêm
  static Future<List<Map<String, dynamic>>> getDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? devicesJson = prefs.getString(_storageKey);
    
    if (devicesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(devicesJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Cập nhật trạng thái ON/OFF
  static Future<void> updateDeviceStatus(String name, bool isOn) async {
    final prefs = await SharedPreferences.getInstance();
    final String? devicesJson = prefs.getString(_storageKey);
    if (devicesJson == null) return;

    List<dynamic> devices = jsonDecode(devicesJson);
    for (var i = 0; i < devices.length; i++) {
       if (devices[i]['name'] == name) {
         devices[i]['isOn'] = isOn;
         break;
       }
    }
    await prefs.setString(_storageKey, jsonEncode(devices));
  }

  // Xóa toàn bộ thiết bị (để test)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
