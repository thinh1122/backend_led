import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/device_setup/connecting_device_screen.dart';

class ConnectDeviceScreen extends StatefulWidget {
  final String deviceName;
  final String deviceImage;

  const ConnectDeviceScreen({
    super.key,
    required this.deviceName,
    required this.deviceImage,
  });

  @override
  State<ConnectDeviceScreen> createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> {
  bool _isChecked = true;

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Bật thiết bị và xác nhận xem đèn tín hiệu có nhấp nháy nhanh hay không.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: _isChecked,
                      onChanged: (v) {
                        setState(() {
                          _isChecked = v ?? false;
                        });
                      },
                      shape: const CircleBorder(),
                      activeColor: const Color(0xFF2962FF),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
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
              
              // Device Visualization
              Container(
                 width: 280,
                 height: 280,
                 alignment: Alignment.center,
                 child: widget.deviceName == 'Smart Lamp' && widget.deviceImage.isEmpty ? 
                   const Icon(
                     Icons.lightbulb_rounded,
                     size: 180,
                     color: Color(0xFFFFC107), // Amber/Yellow
                   ) : Image.asset(widget.deviceImage, width: 200, fit: BoxFit.contain),
              ),
              
              const Spacer(),
              
              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => ConnectingDeviceScreen(
                         deviceName: widget.deviceName,
                         deviceImage: widget.deviceImage,
                       )),
                     );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kết nối',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
