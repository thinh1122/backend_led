
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as Math;

import 'package:iot_project/screens/device_setup/connect_device_screen.dart';
import 'package:iot_project/screens/device_setup/scanner_screen.dart';
import 'package:iot_project/services/bluetooth_service.dart' as iot_ble;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:iot_project/screens/device_setup/ble_provisioning_screen.dart';
import 'package:iot_project/theme.dart';
import 'dart:async';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  int _selectedTab = 0; // 0: Nearby, 1: Manual
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Phổ biến', 'Chiếu sáng', 'Camera', 'Điện gia dụng', 'Bảo mật'];
  
  // Real Nearby Devices
  List<ScanResult> _nearbyDevices = [];
  StreamSubscription? _scanSubscription;
  bool _isScanning = false;

  // Data for Manual Devices
  final List<Map<String, String>> _manualDevices = [
    {
      'name': 'CCTV Thông minh V1',
      'image': 'assets/images/Smart_V1_CCTV.png',
    },
    {
      'name': 'Webcam Thông minh',
      'image': 'assets/images/Smart_Webcam.png',
    },
    {
      'name': 'CCTV Thông minh V2',
      'image': 'assets/images/Smart_V2_CCTV.png',
    },
    {
      'name': 'Đèn Thông minh',
      'image': 'assets/images/Smart_Lamp.png',
    },
    {
      'name': 'Loa Thông minh',
      'image': 'assets/images/Smart_Speaker.png',
    },
    {
      'name': 'Bộ định tuyến Wifi',
      'image': 'assets/images/Wifi_Router.png',
    },
    {
      'name': 'Máy điều hòa',
      'image': 'assets/images/Air_Conditioner.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Speed of one ripple wave
    )..repeat();

    _startNearbyScan();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Khi user quay lại app từ Settings, thử scan lại
    if (state == AppLifecycleState.resumed && !_isScanning) {
      _startNearbyScan();
    }
  }

  Future<void> _startNearbyScan() async {
    final isReady = await iot_ble.BluetoothService.checkAndRequestBluetooth(context);
    if (!isReady) return;

    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _nearbyDevices = [];
    });

    try {
      // iOS: Không dùng withKeywords vì iOS cache và filter khác Android
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        // Bỏ withKeywords để iOS có thể thấy tất cả devices
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            // Filter sau khi nhận results
            _nearbyDevices = results.where((r) {
              final name = r.device.platformName;
              // Chấp nhận cả device có tên PROV_ hoặc device có advertisementData chứa service UUID
              return name.isNotEmpty && 
                     (name.startsWith("PROV_") || 
                      name.toLowerCase().contains("esp") ||
                      r.advertisementData.serviceUuids.isNotEmpty);
            }).toList();
            
            // Debug: In ra tất cả devices để check
            debugPrint("=== Bluetooth Scan Results ===");
            for (var r in results) {
              debugPrint("Device: ${r.device.platformName} | ID: ${r.device.remoteId} | RSSI: ${r.rssi}");
              debugPrint("  Services: ${r.advertisementData.serviceUuids}");
            }
          });
        }
      });

      await Future.delayed(const Duration(seconds: 15));
      if (mounted) {
        setState(() => _isScanning = false);
      }
    } catch (e) {
      debugPrint("Lỗi quét Nearby: $e");
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
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
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.viewfinder, color: Colors.black87, size: 28),
            onPressed: () async {
              // ===== Check Bluetooth trước khi mở Scanner (giống Home) =====
              final isReady = await iot_ble.BluetoothService.checkAndRequestBluetooth(context);
              if (!isReady) return;

              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScannerScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Custom Segmented Control
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabItem('Thiết bị lân cận', 0),
                  ),
                  Expanded(
                    child: _buildTabItem('Thêm thủ công', 1),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Content Body
            Expanded(
              child: _selectedTab == 0 ? _buildNearbyContent() : _buildManualContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A80F0) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  // -------------------- NEARBY CONTENT --------------------
  Widget _buildNearbyContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Đang tìm thiết bị lân cận...',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         const Icon(Icons.wifi, size: 16, color: Color(0xFF2962FF)),
                         const SizedBox(width: 6),
                         const Icon(Icons.bluetooth, size: 16, color: Color(0xFF2962FF)),
                         const SizedBox(width: 8),
                         Text(
                           'Bật Wifi & Bluetooth để kết nối',
                           style: GoogleFonts.inter(
                             fontSize: 12,
                             color: Colors.grey.shade600,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                      ],
                    ),
                  ),
          
                  const Spacer(), // Dùng Spacer để đẩy radar vào giữa
          
                  Center(
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildRipple(0),
                          _buildRipple(0.5),
                          _buildRipple(1.0),
                          
                          // Device List OR Main Avatar
                          if (_nearbyDevices.isEmpty)
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/avtAD.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            ..._nearbyDevices.asMap().entries.map((entry) {
                              int idx = entry.key;
                              ScanResult result = entry.value;
                              
                              double angle = (idx * (360 / _nearbyDevices.length)) * (3.14159 / 180);
                              double radius = 100.0;
                              double x = radius * Math.cos(angle);
                              double y = radius * Math.sin(angle);
          
                              return Transform.translate(
                                offset: Offset(x, y),
                                child: GestureDetector(
                                  onTap: () {
                                    final name = result.device.platformName;
                                    final hwId = name.replaceFirst("PROV_", "");
                                    
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BleProvisioningScreen(
                                          deviceName: "Smart Device", 
                                          hardwareId: hwId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
                                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                                        ),
                                          child: Icon(Icons.bluetooth_audio, color: AppTheme.primaryColor, size: 24),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          result.device.platformName.replaceFirst("PROV_", ""),
                                          style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(), // Dùng tiếp Spacer để đẩy Button xuống đáy
          
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nearbyDevices.isEmpty ? null : () {
                          final firstDevice = _nearbyDevices.first;
                          final name = firstDevice.device.platformName;
                          final hwId = name.replaceFirst("PROV_", "");
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BleProvisioningScreen(
                                deviceName: "Smart Device", 
                                hardwareId: hwId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _nearbyDevices.isEmpty ? Colors.grey[300] : const Color(0xFF4A80F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _nearbyDevices.isEmpty ? 'Đang tìm thiết bị...' : 'Kết nối thiết bị (${_nearbyDevices.length})',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Giảm spacing để dính sát hơn
                  Text(
                    'Không tìm thấy thiết bị?',
                    style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Tìm hiểu thêm',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF4A80F0),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------- MANUAL CONTENT --------------------
  Widget _buildManualContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(_categories.length, (index) {
              final isSelected = _selectedCategoryIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(_categories[index]),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF4A80F0),
                  labelStyle: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _manualDevices.length,
            itemBuilder: (context, index) {
              final device = _manualDevices[index];
              return Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConnectDeviceScreen(
                              deviceName: device['name']!,
                              deviceImage: device['image']!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.asset(
                              device['image']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    device['name']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRipple(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = (_controller.value + delay) % 1.0;
        final size = 80 + (240 * t);
        final opacity = 1.0 - t; 

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF4A80F0).withOpacity(0.5 * opacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }
}
