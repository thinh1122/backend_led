import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/device_setup/add_device_screen.dart';
import 'package:iot_project/screens/dashboard/tabs/account_tab.dart';
import 'package:iot_project/screens/dashboard/tabs/home_tab.dart';
import 'package:iot_project/theme.dart';
import 'package:iot_project/services/mqtt_service.dart';
import 'package:iot_project/screens/device_setup/scanner_screen.dart';
import 'package:iot_project/services/bluetooth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<HomeTabState> _homeKey = GlobalKey<HomeTabState>();
  int _selectedIndex = 0;
  bool _isAddMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _initMqtt();
  }

  void _initMqtt() async {
    final mqttService = MqttService();
    await mqttService.connect();
    // Subscribe to a general status topic if needed
    mqttService.subscribe('smarthome/devices/+/state');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF2F2F7), // Light grey background
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                HomeTab(key: _homeKey),
                Center(child: Text('Tính năng Thông minh (Sắp ra mắt)', style: GoogleFonts.outfit(fontSize: 18))),
                Center(child: Text('Báo cáo thống kê (Sắp ra mắt)', style: GoogleFonts.outfit(fontSize: 18))),
                AccountTab(
                  onRefreshHome: () {
                    debugPrint("HomeScreen: Received reload request from AccountTab");
                    _homeKey.currentState?.refresh();
                  }
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            elevation: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                activeIcon: Icon(CupertinoIcons.house_fill),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.checkmark_shield),
                label: 'Thông minh',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.graph_square),
                label: 'Báo cáo',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),

        // FAB Layout (Only show on Home Tab)
        if (_selectedIndex == 0) ...[
          
          // 0. Mic Button (Restore)
          Positioned(
            bottom: 99,
            right: 100,
            child: SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                heroTag: 'mic',
                backgroundColor: const Color(0xFFE0E6FF),
                elevation: 0,
                onPressed: () {},
                shape: const CircleBorder(),
                child: const Icon(CupertinoIcons.mic, color: AppTheme.primaryColor, size: 28),
              ),
            ),
          ),


          // 1. Overlay
          if (_isAddMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isAddMenuOpen = false),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),

          // 2. Add Menu
          if (_isAddMenuOpen)
            Positioned(
              bottom: 175,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 220,
                      child: Column(
                        children: [
                          _buildMenuItem(CupertinoIcons.briefcase, 'Thêm thiết bị'),
                          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                          _buildMenuItem(CupertinoIcons.viewfinder, 'Quét mã'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 22),
                    child: CustomPaint(
                      painter: TrianglePainter(),
                      size: const Size(20, 10),
                    ),
                  ),
                ],
              ),
            ),

          // 3. Add/Close FAB
          Positioned(
            bottom: 95,
            right: 20,
            child: SizedBox(
              width: 64,
              height: 64,
              child: FloatingActionButton(
                heroTag: 'add',
                backgroundColor: AppTheme.primaryColor,
                elevation: 4,
                onPressed: () {
                  setState(() {
                    _isAddMenuOpen = !_isAddMenuOpen;
                  });
                },
                shape: const CircleBorder(),
                child: Icon(
                  _isAddMenuOpen ? Icons.close : CupertinoIcons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return InkWell(
      onTap: () async {
        if (label == 'Thêm thiết bị') {
          setState(() => _isAddMenuOpen = false); 
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
          );
          await Future.delayed(const Duration(milliseconds: 500)); // Đợi DB sync
          _homeKey.currentState?.refresh();
        } else if (label == 'Quét mã') {
          setState(() => _isAddMenuOpen = false);
          
          // ===== NEW: Check Bluetooth trước khi mở Scanner =====
          final isReady = await BluetoothService.checkAndRequestBluetooth(context);
          if (!isReady) {
            // Bluetooth chưa sẵn sàng, dialog đã hiển
            return;
          }
          
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          );
          await Future.delayed(const Duration(milliseconds: 500)); // Đợi DB sync
          _homeKey.currentState?.refresh();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22), 
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87), 
            const SizedBox(width: 16), 
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
