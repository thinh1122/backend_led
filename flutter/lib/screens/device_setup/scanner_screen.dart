import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:iot_project/theme.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert';
import 'package:iot_project/services/api_service.dart';

import 'package:image_picker/image_picker.dart';
import 'package:iot_project/screens/device_setup/ble_provisioning_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  bool _isScanned = false;
  bool _isProcessing = false;
  bool _cameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() => _cameraPermissionGranted = true);
    } else {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        setState(() => _cameraPermissionGranted = true);
      } else {
        _showCameraPermissionDialog();
      }
    }
  }

  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(
          Icons.camera_alt_outlined,
          size: 56,
          color: Colors.orange[400],
        ),
        title: Text(
          "Cần quyền Camera",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Ứng dụng cần quyền truy cập Camera để quét mã QR thiết bị. Vui lòng cấp quyền trong Cài đặt.",
          style: GoogleFonts.outfit(),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Quay về màn trước
            },
            child: Text(
              "Hủy",
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "MỞ CÀI ĐẶT",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isProcessing = true);
    
    try {
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? code = capture.barcodes.first.rawValue;
        if (code != null) {
          await _handleScannedCode(code);
        }
      } else {
        _showErrorDialog("Không tìm thấy mã QR trong ảnh này!");
      }
    } catch (e) {
      _showErrorDialog("Lỗi khi xử lý ảnh!");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraPermissionGranted) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 80, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                "Đang chờ quyền Camera...",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Scanner Preview
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isScanned || _isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScannedCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // 2. Custom Overlay (Hole in the middle)
          _buildOverlay(context),

          // 3. App Bar
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Quét thiết bị',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // 4. Bottom Controls
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Không thể quét được mã QR?",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Chuyển sang màn hình nhập mã thủ công
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "Nhập mã cài đặt thủ công",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // GIẢ LẬP QUÉT FILE QR.PNG TRONG ASSETS
                        final mockJsonFromAsset = jsonEncode({
                          "hw_id": "thiet_bi_esp32", // ID CứNG CỦA ESP32 (KHỚP VỚI FIRMWARE)
                          "name": "Đèn thông minh",
                          "type": "Wi-Fi",
                          "image": "assets/images/Smart_Lamp.png",
                          "isCamera": false
                        });
                        _handleScannedCode(mockJsonFromAsset);
                      },
                      child: _buildCircleAction(CupertinoIcons.folder_fill)
                    ),
                    // Central button
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (_isProcessing)
                            const CircularProgressIndicator(color: Colors.blue)
                          else
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: 0.25,
                                strokeWidth: 4,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: _buildCircleAction(CupertinoIcons.photo_fill)
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Stack(
      children: [
        // Sử dụng CustomPainter để tạo lớp phủ đục lỗ
        Positioned.fill(
          child: CustomPaint(
            painter: HolePainter(),
          ),
        ),
        // Brackets
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: ScannerFramePainter(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleScannedCode(String rawCode) async {
    if (_isProcessing) return;
    
    setState(() {
      _isScanned = true;
      _isProcessing = true;
    });

    try {
      // 1. Phân tách dữ liệu JSON từ QR Code
      final Map<String, dynamic> deviceData = jsonDecode(rawCode);
      final String name = deviceData['name'] ?? "Thiết bị mới";
      final String type = deviceData['type'] ?? "Wi-Fi";
      // ignore: unused_local_variable
      final String image = deviceData['image'] ?? "assets/images/Smart_Lamp.png";
      // ignore: unused_local_variable
      final bool isCamera = deviceData['isCamera'] ?? false;
      final String hardwareId = deviceData['hw_id'] ?? ""; // LẤY HW_ID

      // ===== NEW: BLE Provisioning Flow =====
      // Không cần user switch WiFi nữa, dùng Bluetooth!
      
      if (hardwareId.isEmpty) {
        _showErrorDialog("QR Code không chứa Hardware ID!");
        return;
      }

      if (mounted) {
        // Chuyển sang màn BLE Provisioning
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BleProvisioningScreen(
              deviceName: name,
              hardwareId: hardwareId,
            ),
          ),
        );
        
        // Nếu thành công (result == true), đóng Scanner và báo về Home
        if (result == true && mounted) {
          Navigator.pop(context, true); 
        }
      }
    } catch (e) {
      debugPrint("Lỗi quét mã: $e");
      _showErrorDialog("Dữ liệu mã QR không hợp lệ!");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(String deviceName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              "Thêm thành công!",
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Đã thêm '$deviceName' vào danh sách thiết bị của bạn.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Đóng BottomSheet
                Navigator.pop(context); // Quay về Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                "Xong", 
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        action: SnackBarAction(
          label: "Thử lại", 
          textColor: Colors.white,
          onPressed: () => setState(() => _isScanned = false),
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);
    
    // Tạo path cho toàn màn hình và một lỗ tròn/vuông ở giữa
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: 280, height: 280),
            const Radius.circular(30),
          ))
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double length = 40;
    const double radius = 30;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(0, length)
        ..lineTo(0, radius)
        ..quadraticBezierTo(0, 0, radius, 0)
        ..lineTo(length, 0),
      paint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - length, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, length),
      paint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - length)
        ..lineTo(0, size.height - radius)
        ..quadraticBezierTo(0, size.height, radius, size.height)
        ..lineTo(length, size.height),
      paint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - length, size.height)
        ..lineTo(size.width - radius, size.height)
        ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
        ..lineTo(size.width, size.height - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
