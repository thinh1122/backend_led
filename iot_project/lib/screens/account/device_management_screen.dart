import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/theme.dart';
import 'package:iot_project/services/api_service.dart';
import 'package:iot_project/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart'; // Import MqttConnectionState

class DeviceManagementScreen extends StatefulWidget {
  final VoidCallback? onDeviceChanged;
  const DeviceManagementScreen({super.key, this.onDeviceChanged});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getMyDevices();
      if (response.statusCode == 200) {
        setState(() {
          _devices = response.data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách thiết bị: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDevice(String id, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Xác nhận xóa', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc chắn muốn xóa thiết bị "$name" không?',
          style: GoogleFonts.outfit(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Xóa', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 1. Gửi lệnh Reset WiFi tới ESP32 qua MQTT
    try {
      final String slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      final String topic = 'smarthome/devices/$slug/set';
      
      debugPrint("Sending RESET_WIFI to $topic");
      
      final mqtt = MqttService();
      // Đảm bảo kết nối
      if (mqtt.client == null || mqtt.client?.connectionStatus?.state != MqttConnectionState.connected) {
         await mqtt.connect();
      }
      
      mqtt.publish(topic, "RESET_WIFI");
      
      // Đợi 1 chút để lệnh bay đi (QoS 0)
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      debugPrint("Lỗi gửi MQTT Reset: $e");
      // Không return, vẫn tiếp tục xóa khỏi DB
    }

    // 2. Xóa khỏi Database
    try {
      final response = await _apiService.deleteDevice(id);
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi lệnh Reset & Xóa thiết bị!')),
          );
          _loadDevices(); 
          widget.onDeviceChanged?.call(); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa thiết bị: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light Gray Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Thiết bị của tôi",
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.devices_other, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "Chưa có thiết bị nào",
                        style: GoogleFonts.outfit(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: _devices.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return _buildDeviceItem(device);
                  },
                ),
    );
  }

  Widget _buildDeviceItem(dynamic device) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            device['image'] ?? 'assets/images/Smart_Lamp.png',
            errorBuilder: (ctx, err, stack) => const Icon(Icons.device_unknown, color: AppTheme.primaryColor),
          ),
        ),
        title: Text(
          device['name'] ?? 'Không tên',
          style: GoogleFonts.outfit(
            color: Colors.black, // Text Black
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ]
                ),
              ),
              const SizedBox(width: 6),
              Text(
                device['type'] ?? 'Wi-Fi Device',
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        trailing: InkWell(
          onTap: () => _deleteDevice(
            device['id'].toString(),
            device['name'],
          ),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ),
      ),
    );
  }
}
