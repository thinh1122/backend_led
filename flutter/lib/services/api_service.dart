import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iot_project/core/app_config.dart';

class ApiService {
  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Quản lý nhà
  Future<Response> createHouse(String name, String address, List<String> roomNames) async {
    try {
      return await _dio.post("/houses", data: {
        "name": name,
        "address": address,
        "roomNames": roomNames,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> getMyHouses() async {
    try {
      return await _dio.get("/houses");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Danh sách thiết bị
  Future<Response> getMyDevices() async {
    try {
      return await _dio.get("/devices");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> addDevice(String name, String image, {String? type, bool isCamera = false, String? hardwareId, String? roomId}) async {
    try {
      return await _dio.post("/devices", data: {
        "name": name,
        "image": image,
        "type": type ?? "Wi-Fi",
        "isCamera": isCamera,
        "hardwareId": hardwareId,
        "roomId": roomId,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Quản lý phòng
  Future<List<Map<String, dynamic>>> getMyRooms() async {
    try {
      final response = await _dio.get("/houses");
      List<Map<String, dynamic>> allRooms = [];
      
      if (response.statusCode == 200 && response.data is List) {
        for (var house in response.data) {
          if (house['rooms'] != null) {
            for (var room in house['rooms']) {
              allRooms.add({
                'id': room['id'],
                'name': room['name'],
                'houseName': house['name'],
              });
            }
          }
        }
      }
      return allRooms;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Bật tắt thiết bị
  Future<Response> toggleDevice(String id, bool isOn) async {
    try {
      return await _dio.post("/devices/$id/toggle", queryParameters: {
        "isOn": isOn
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> deleteDevice(String id) async {
    try {
      return await _dio.delete("/devices/$id");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Đăng ký
  Future<Response> signup(String email, String password) async {
    try {
      final response = await _dio.post("/auth/signup", data: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        // Lưu token ngay sau khi đăng ký thành công
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data['token']);
        await prefs.setString('email', response.data['email']);
      }
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Đăng nhập
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post("/auth/login", data: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        // Lưu token vào máy
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data['token']);
        await prefs.setString('email', response.data['email']);
      }
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ===== SCHEDULE API =====
  Future<List<Map<String, dynamic>>> getSchedulesByDevice(dynamic deviceId) async {
    try {
      final response = await _dio.get("/schedules/device/$deviceId");
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> createSchedule({
    required dynamic deviceId,
    required String time,
    required String action,
    String? name,
    bool enabled = true,
    String repeatDays = "1,2,3,4,5,6,7",
  }) async {
    try {
      return await _dio.post("/schedules", data: {
        "deviceId": deviceId,
        "time": time,
        "action": action,
        "name": name,
        "enabled": enabled,
        "repeatDays": repeatDays,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> updateSchedule(
    int scheduleId, {
    String? time,
    String? action,
    bool? enabled,
    String? name,
    String? repeatDays,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (time != null) data['time'] = time;
      if (action != null) data['action'] = action;
      if (enabled != null) data['enabled'] = enabled;
      if (name != null) data['name'] = name;
      if (repeatDays != null) data['repeatDays'] = repeatDays;

      return await _dio.put("/schedules/$scheduleId", data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> deleteSchedule(int scheduleId) async {
    try {
      return await _dio.delete("/schedules/$scheduleId");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      
      // 1. Luôn ưu tiên tin nhắn từ Server trả về (JSON)
      if (data is Map) {
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('error')) return data['error'].toString();
      }
      
      // 2. Nếu server trả về dạng String (không phải JSON)
      if (data is String && data.isNotEmpty) {
        if (!data.contains("<!DOCTYPE html>")) { // Tránh trả về nguyên code HTML lỗi
           return data;
        }
      }

      // 3. Nếu không có tin nhắn cụ thể, mới dùng theo StatusCode
      if (e.response?.statusCode == 401) return "Phiên làm việc hết hạn, vui lòng đăng nhập lại!";
      if (e.response?.statusCode == 403) return "Bạn không có quyền truy cập hoặc Token không hợp lệ. Hãy thử đăng xuất và đăng nhập lại!";
      if (e.response?.statusCode == 404) return "Không tìm thấy yêu cầu trên Server!";
      if (e.response?.statusCode == 500) return "Lỗi hệ thống Server (500). Thử lại sau!";
    }
    
    if (e.type == DioExceptionType.connectionTimeout) return "Kết nối quá hạn, hãy kiểm tra mạng!";
    if (e.type == DioExceptionType.receiveTimeout) return "Server phản hồi chậm, thử lại sau!";
    
    return "Không thể kết nối đến Server. Hãy kiểm tra địa chỉ IP trong AppConfig!";
  }
}
