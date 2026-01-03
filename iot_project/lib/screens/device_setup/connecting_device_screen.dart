import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/device_setup/success_connection_screen.dart';
import 'package:iot_project/services/device_service.dart';
import 'package:iot_project/services/api_service.dart';

class ConnectingDeviceScreen extends StatefulWidget {
  final String deviceName;
  final String deviceImage;

  const ConnectingDeviceScreen({
    super.key,
    required this.deviceName,
    required this.deviceImage,
  });

  @override
  State<ConnectingDeviceScreen> createState() => _ConnectingDeviceScreenState();
}

class _ConnectingDeviceScreenState extends State<ConnectingDeviceScreen> {
  int _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) async {
      if (_progress >= 100) {
        timer.cancel();
        
        // 1. Save to Local Cache
        await DeviceService.addDevice(widget.deviceName, widget.deviceImage);
        
        // 2. Save to Backend Account
        try {
          final apiService = ApiService();
          final isCamera = widget.deviceName.toLowerCase().contains('cctv') || 
                           widget.deviceName.toLowerCase().contains('webcam') ||
                           widget.deviceName.toLowerCase().contains('camera');
          
          await apiService.addDevice(
            widget.deviceName, 
            widget.deviceImage,
            isCamera: isCamera,
          );
        } catch (e) {
          debugPrint("Error saving device to backend: $e");
          // Even if backend fails, we have it in local cache for now
        }

        _navigateToSuccess();
      } else {
        setState(() {
          _progress++;
        });
      }
    });
  }

  void _navigateToSuccess() {
    // Small delay before navigating to make it feel natural
    Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
           Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SuccessConnectionScreen(
              deviceName: widget.deviceName,
              deviceImage: widget.deviceImage,
            )),
          );
        }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thêm thiết bị',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                'Kết nối thiết bị',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Wifi & Bluetooth Tip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                   mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                         color: Color(0xFF2962FF), // Primary Blue
                         shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wifi, color: Colors.white, size: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                         color: Color(0xFF2962FF), // Primary Blue
                         shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bluetooth, color: Colors.white, size: 12),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bật Wifi & Bluetooth để kết nối',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Smart Lamp Check
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                     decoration: const BoxDecoration(
                       shape: BoxShape.circle,
                       color: Color(0xFF2962FF),
                     ),
                     child: const Padding(
                       padding: EdgeInsets.all(4.0),
                       child: Icon(Icons.check, size: 12, color: Colors.white),
                     ),
                   ),
                   const SizedBox(width: 12),
                  Text(
                    widget.deviceName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Progress Circle and Image
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Circle
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: _progress / 100, 
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2962FF)),
                      ),
                    ),
                    // Image
                    Padding(
                      padding: const EdgeInsets.all(40.0), // Padding to keep image inside circle
                      child: Image.asset(
                        widget.deviceImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              
              Text(
                'Đang kết nối...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_progress%',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2962FF),
                ),
              ),
              
              const Spacer(),
              
              const SizedBox(height: 24),
              // Bottom Links
              Text(
                'Không thể kết nối với thiết bị?',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () {},
                 style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(top: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Tìm hiểu thêm',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2962FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
