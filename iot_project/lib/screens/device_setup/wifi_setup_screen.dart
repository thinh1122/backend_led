import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:iot_project/services/api_service.dart';

class WifiSetupScreen extends StatefulWidget {
  final String deviceName;
  final String? hardwareId;
  const WifiSetupScreen({super.key, required this.deviceName, this.hardwareId});

  @override
  State<WifiSetupScreen> createState() => _WifiSetupScreenState();
}

class _WifiSetupScreenState extends State<WifiSetupScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isConnecting = false;
  String _statusMessage = "";

  void _startProvisioning() async {
    if (_ssidController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin WiFi")),
      );
      return;
    }
    setState(() {
      _isConnecting = true;
      _statusMessage = "Đang kết nối tới Chip (192.168.4.1)...";
    });

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      baseUrl: 'http://192.168.4.1',
    ));

    try {
      // 1. Gửi cấu hình WiFi
      setState(() => _statusMessage = "Đang gửi thông tin WiFi...");
      
      final response = await dio.post('/api/wifi', data: {
        "ssid": _ssidController.text,
        "password": _passController.text
      });

      if (response.statusCode == 200 || response.data == "OK") {
         if (mounted) {
           // Dừng loading wifi
           setState(() => _isConnecting = false);

           // 1. Nhắc người dùng kết nối lại Internet để lưu vào Server
           bool? ready = await showDialog<bool>(
             context: context,
             barrierDismissible: false,
             builder: (ctx) => AlertDialog(
               title: const Text("Bước 1 hoàn tất!"),
               content: const Text(
                 "Chip đã nhận WiFi và đang khởi động lại.\n\n"
                 "❗ QUAN TRỌNG: Vui lòng kết nối lại Internet cho điện thoại để tiếp tục bước 2.\n\n"
                 "1. Tắt kết nối với 'PROV_SMART'.\n"
                 "2. Kết nối lại WiFi nhà hoặc bật 4G.\n"
                 "3. Bấm nút dưới đây để lưu thiết bị."
               ),
               actions: [
                 TextButton(
                   onPressed: () => Navigator.pop(ctx, true),
                   style: TextButton.styleFrom(
                     backgroundColor: AppTheme.primaryColor,
                     foregroundColor: Colors.white,
                   ),
                   child: const Text("TÔI ĐÃ CÓ MẠNG INTERNET"),
                 ),
               ],
             ),
           );

           if (ready == true) {
             // 2. Gọi API thêm thiết bị khi đã có mạng
             await _addDeviceToServer(); 
           }
         }
      } else {
        throw Exception("Server trả về lỗi: ${response.statusCode}");
      }

    } catch (e) {
      debugPrint("Lỗi Provisioning: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: Không thể gửi Wifi tới Chip. Hãy chắc chắn bạn đã kết nối vào WiFi: PROV_SMART"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Cấu hình thành công!", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text("Chip đã nhận được thông tin và đang khởi động lại để kết nối WiFi nhà bạn.", textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng Dialog
              Navigator.of(context).pop(true); // Quay về Home và báo (true) để refresh
            },
            child: const Text("Tiếp tục"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Cài đặt WiFi", style: GoogleFonts.outfit(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kết nối ${widget.deviceName}",
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "1. Mở Cài đặt WiFi trên điện thoại.\n2. Kết nối vào WiFi: PROV_SMART.\n3. Nhập SSID/Mật khẩu WiFi nhà bạn vào dưới đây.",
              style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            
            // SSID Field
            _buildTextField("Tên WiFi nhà bạn (SSID)", _ssidController, CupertinoIcons.wifi),
            const SizedBox(height: 16),
            
            // Password Field
            _buildTextField("Mật khẩu WiFi nhà bạn", _passController, CupertinoIcons.lock, isPassword: true),
            
            const SizedBox(height: 16),
            
            if (_isConnecting) ...[
              Center(
                child: Text(
                  _statusMessage,
                  style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _startProvisioning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isConnecting 
                   ? const CircularProgressIndicator(color: Colors.white)
                  : Text("GỬI CẤU HÌNH WIFI", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          ],
        ),
      ),
    );
  }


  Future<void> _addDeviceToServer() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = "Đang lưu thiết bị vào tài khoản...";
    });

    try {
      final apiService = ApiService();
      
      // userId được lấy tự động từ Token trong ApiService
      // roomId được Backend tự chọn mặc định nếu không truyền
      await apiService.addDevice(
        widget.deviceName, 
        "assets/images/Smart_Lamp.png", 
        type: "Wi-Fi",
        hardwareId: widget.hardwareId 
      );

      if (mounted) _showSuccessDialog();

    } catch (e) {
      debugPrint("Lỗi Add Device: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: Colors.grey.shade200)
        ),
      ),
    );
  }
}
