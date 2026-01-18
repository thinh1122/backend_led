import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/theme.dart';

/// Service để kiểm tra và yêu cầu quyền Bluetooth
class BluetoothService {
  
  /// Kiểm tra tất cả điều kiện cần thiết cho BLE
  /// Trả về true nếu sẵn sàng, false nếu không
  static Future<bool> checkAndRequestBluetooth(BuildContext context) async {
    // 1. Check Bluetooth adapter state
    final adapterState = await FlutterBluePlus.adapterState.first;
    
    if (adapterState != BluetoothAdapterState.on) {
      // Bluetooth đang tắt
      final shouldTurnOn = await _showBluetoothOffDialog(context);
      if (shouldTurnOn) {
        try {
          // Android có thể bật trực tiếp
          if (Platform.isAndroid) {
            await FlutterBluePlus.turnOn();
            // Chờ một chút để Bluetooth bật
            await Future.delayed(const Duration(seconds: 2));
            final newState = await FlutterBluePlus.adapterState.first;
            if (newState != BluetoothAdapterState.on) {
              return false;
            }
          } else {
            // iOS phải mở Settings
            await openAppSettings();
            return false;
          }
        } catch (e) {
          debugPrint("Error turning on Bluetooth: $e");
          return false;
        }
      } else {
        return false;
      }
    }
    
    // 2. Check permissions (Android)
    if (Platform.isAndroid) {
      // Bluetooth Scan permission
      final bleScanStatus = await Permission.bluetoothScan.status;
      if (!bleScanStatus.isGranted) {
        final result = await Permission.bluetoothScan.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog(context, "Bluetooth Scan");
          return false;
        }
      }
      
      // Bluetooth Connect permission
      final bleConnectStatus = await Permission.bluetoothConnect.status;
      if (!bleConnectStatus.isGranted) {
        final result = await Permission.bluetoothConnect.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog(context, "Bluetooth Connect");
          return false;
        }
      }
      
      // Location permission (required for BLE scan on Android)
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        final result = await Permission.location.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog(context, "Vị trí");
          return false;
        }
      }
      
      // Check if Location service is enabled
      final locationServiceEnabled = await Permission.location.serviceStatus.isEnabled;
      if (!locationServiceEnabled) {
        final shouldEnable = await _showLocationServiceDialog(context);
        if (shouldEnable) {
          await openAppSettings();
        }
        return false;
      }
    }
    
    // 3. iOS - just check Bluetooth permission (handled by system)
    if (Platform.isIOS) {
      final bleStatus = await Permission.bluetooth.status;
      if (!bleStatus.isGranted) {
        final result = await Permission.bluetooth.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog(context, "Bluetooth");
          return false;
        }
      }
    }
    
    return true;
  }
  
  /// Dialog khi Bluetooth tắt
  static Future<bool> _showBluetoothOffDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(
          Icons.bluetooth_disabled,
          size: 56,
          color: Colors.grey[400],
        ),
        title: Text(
          "Bluetooth chưa bật",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Vui lòng bật Bluetooth để tìm và kết nối thiết bị thông minh.",
          style: GoogleFonts.outfit(),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Để sau",
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "BẬT BLUETOOTH",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// Dialog khi Location service tắt
  static Future<bool> _showLocationServiceDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(
          Icons.location_off,
          size: 56,
          color: Colors.grey[400],
        ),
        title: Text(
          "Vị trí chưa bật",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Trên Android, tính năng quét Bluetooth cần bật Dịch vụ vị trí. Vui lòng bật trong Cài đặt.",
          style: GoogleFonts.outfit(),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Để sau",
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
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
    ) ?? false;
  }
  
  /// Dialog khi permission bị từ chối
  static void _showPermissionDeniedDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(
          Icons.warning_amber_rounded,
          size: 56,
          color: Colors.orange[400],
        ),
        title: Text(
          "Thiếu quyền truy cập",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Quyền $permission cần được cấp để kết nối thiết bị. Vui lòng vào Cài đặt > Ứng dụng để cấp quyền.",
          style: GoogleFonts.outfit(),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Đã hiểu",
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
}
