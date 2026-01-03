import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/device_setup/add_device_screen.dart';
import 'package:iot_project/screens/device_control/control_device_screen.dart';
import 'package:iot_project/theme.dart';
import 'package:iot_project/services/api_service.dart';
import 'package:iot_project/services/device_service.dart';
import 'package:iot_project/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';
import 'dart:async';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final MqttService _mqttService = MqttService();
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _mqttSubscription;
  
  String _selectedRoom = 'Tất cả phòng';
  String _homeName = 'Nhà của tôi';
  List<String> _rooms = ['Tất cả phòng', 'Phòng khách', 'Phòng ngủ', 'Phòng bếp'];
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initMqttAndLoad();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mqttSubscription?.cancel();
    _mqttSubscription = null;
    debugPrint("HomeTab: Disposed, MQTT subscription cancelled");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("HomeTab: App resumed, reconnecting MQTT...");
      _setupMqttListener();
    }
  }

  /// Khởi tạo MQTT và load dữ liệu ban đầu
  Future<void> _initMqttAndLoad() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    await _setupMqttListener();
    await _loadHomeData();
    await _loadDevices();
    
    if (mounted) setState(() => _isLoading = false);
  }

  /// Setup MQTT listener với quản lý subscription đúng cách
  Future<void> _setupMqttListener() async {
    debugPrint("HomeTab: Setting up MQTT listener...");
    
    // 1. Hủy subscription cũ (nếu có)
    await _mqttSubscription?.cancel();
    _mqttSubscription = null;
    
    // 2. Kết nối MQTT
    final connected = await _mqttService.connect();
    if (!connected) {
      debugPrint("HomeTab: ❌ MQTT connection failed");
      return;
    }
    
    // 3. Subscribe topic
    _mqttService.subscribe('smarthome/devices/+/state');
    
    // 4. Đăng ký listener MỚI và lưu subscription reference
    _mqttSubscription = _mqttService.messagesStream?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      _handleMqttMessage(c);
    }, onError: (error) {
      debugPrint("HomeTab: ❌ MQTT Stream error: $error");
    }, onDone: () {
      debugPrint("HomeTab: ⚠️ MQTT Stream closed, will reconnect on resume");
    });
    
    debugPrint("HomeTab: ✅ MQTT listener setup complete");
  }

  /// Xử lý message MQTT nhận được
  void _handleMqttMessage(List<MqttReceivedMessage<MqttMessage>> c) {
    if (c.isEmpty) return;
    
    final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
    final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final String topic = c[0].topic;
    
    debugPrint('📩 MQTT Received: Topic=$topic, Payload=$payload');
    
    // Parse slug/ID from topic: smarthome/devices/{id}/state
    final parts = topic.split('/');
    if (parts.length >= 3) {
      final mqttId = parts[2];
      final bool isOn = (payload == 'ON');
      _updateDeviceState(mqttId, isOn);
    }
  }

  /// Cập nhật trạng thái thiết bị dựa trên MQTT message
  void _updateDeviceState(String mqttId, bool isOn) {
    bool found = false;
    
    for (var i = 0; i < _devices.length; i++) {
      final device = _devices[i];
      final String? hwId = device['hardwareId'];
      
      bool isMatch = false;
      
      if (hwId != null && hwId.isNotEmpty) {
        if (hwId == mqttId) isMatch = true;
      } else {
        final deviceName = device['name'].toString();
        final dSlug = _cleanId(deviceName);
        if (dSlug == mqttId) isMatch = true;
      }
      
      if (isMatch) {
        debugPrint("🔄 SYNC: Updating UI for ${device['name']} -> $isOn");
        if (mounted) {
          setState(() {
            _devices[i]['isOn'] = isOn;
          });
        }
        found = true;
        break; // Đã tìm thấy, thoát vòng lặp
      }
    }
    
    if (!found) {
      debugPrint("⚠️ SYNC: No matching device found for '$mqttId'");
    }
  }

  /// Helper: Tạo slug từ tên thiết bị
  String _cleanId(String input) {
    var str = input.toLowerCase();
    str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    str = str.replaceAll(RegExp(r'[đ]'), 'd');
    str = str.replaceAll(RegExp(r'[^a-z0-9]'), '_');
    str = str.replaceAll(RegExp(r'_+'), '_');
    return str;
  }

  /// Refresh dữ liệu (được gọi từ RefreshIndicator)
  Future<void> refresh() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    debugPrint("HomeTab: Refreshing data...");
    
    // Reconnect MQTT và load lại data
    await _setupMqttListener();
    await _loadHomeData();
    await _loadDevices();
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _navigateToControl(Map<String, dynamic> device) {
    final name = device['name'].toString().toLowerCase();
    
    // Chỉ điều hướng nếu là các thiết bị đã làm giao diện
    bool isSupported = name.contains('lamp') || 
                       name.contains('đèn') ||
                       name.contains('cctv') || 
                       name.contains('webcam') || 
                       name.contains('speaker') || 
                       name.contains('loa') || 
                       name.contains('air conditioner') || 
                       name.contains('điều hòa');

    if (isSupported) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ControlDeviceScreen(
            deviceName: device['name'],
            deviceImage: device['image'],
          ),
        ),
      );
    }
  }

  void _toggleDevice(int index, bool value) async {
    final device = _devices[index];
    
    // ƯU TIÊN: Dùng HardwareID nếu có
    final String? hwId = device['hardwareId'];
    final String deviceId = (hwId != null && hwId.isNotEmpty) 
        ? hwId 
        : _cleanId(device['name'].toString());
    
    debugPrint('MQTT Topic ID: $deviceId');
    // 1. Cập nhật giao diện ngay lập tức (Optimistic UI)
    setState(() {
      _devices[index]['isOn'] = value;
    });

    // 2. Gọi Server để xử lý (Lưu DB + Bắn MQTT từ Server)
    try {
      final String id = device['id'].toString(); // UUID từ Backend
      // Gọi API Toggle (Hàm này return Future, nhưng ta không cần await chặn UI)
      _apiService.toggleDevice(id, value).then((_) {
          debugPrint("SYNC: Server confirmed state $value for $id");
      }).catchError((e) {
          debugPrint("SYNC ERROR: Call server failed: $e");
          // Nếu lỗi, có thể revert UI lại nếu muốn (tùy chọn)
          if (mounted) {
             setState(() => _devices[index]['isOn'] = !value);
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi kết nối Server!")));
          }
      });
    } catch (e) {
      debugPrint("SYNC ERROR: General error: $e");
    }
    
    // 3. Cập nhật Local Cache (để khi mở lại app nạp nhanh hơn trước khi fetch server)
    await DeviceService.updateDeviceStatus(device['name'], value);
    

  }

  Future<void> _loadHomeData() async {
    try {
      final response = await _apiService.getMyHouses();
      if (response.statusCode == 200) {
        final List<dynamic> houses = response.data;
        if (houses.isNotEmpty) {
          final house = houses[0];
          setState(() {
            _homeName = house['name'] ?? "Nhà của tôi";
            final List<dynamic> roomList = house['rooms'] ?? [];
            if (roomList.isNotEmpty) {
               _rooms = ['Tất cả phòng', ...roomList.map((r) => r['name'].toString())];
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading home data: $e");
    }
  }

  Future<void> _loadDevices() async {
    List<Map<String, dynamic>> allDevices = [];
    
    // 1. Lấy từ Backend API (SOURCE OF TRUTH)
    try {
      final response = await _apiService.getMyDevices();
      debugPrint("Backend response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> backendDevices = response.data;
        allDevices.addAll(backendDevices.map((d) => Map<String, dynamic>.from(d)).toList());
        debugPrint("Found ${backendDevices.length} backend devices");

        // ĐỒNG BỘ: Nếu Server bảo trống (0 thiết bị) thì cũng xóa luôn Local 
        if (backendDevices.isEmpty) {
          await DeviceService.clearAll();
          debugPrint("SYNC: Đã xóa Local vì Server không có thiết bị nào.");
        } else {
          // Cập nhật local cache theo Backend (để offline mode có data mới nhất)
          for (var device in allDevices) {
            await DeviceService.updateDeviceStatus(
              device['name'].toString(), 
              device['isOn'] == true
            );
          }
          debugPrint("SYNC: Đã cập nhật local cache từ Backend");
        }
      }
    } catch (e) {
      debugPrint("Error loading backend devices: $e");
      
      // FALLBACK: Nếu không kết nối được server, dùng local cache
      final localDevices = await DeviceService.getDevices();
      if (localDevices.isNotEmpty) {
        debugPrint("Using local cache as fallback (${localDevices.length} devices)");
        allDevices.addAll(localDevices);
      }
    }
    
    _devices = allDevices;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildWeatherCard(),
            ),
            const SizedBox(height: 24),
            _buildCategoryCards(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible( // Wrap Text with Flexible to prevent overflow
                    child: Text(
                      'Tất cả thiết bị',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis, // Add overflow handling
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildRoomFilters(),
            const SizedBox(height: 16),
            _buildDeviceGrid(),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Flexible(
            child: Text(
              _homeName,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 28),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF0F3FF), shape: BoxShape.circle),
            child: Icon(CupertinoIcons.person_fill, color: const Color(0xFF246BFD), size: 24),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF9F9F9), shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade100)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(CupertinoIcons.bell, color: Colors.black87, size: 24),
                Positioned(
                  right: -1, top: -1,
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4A80F0), Color(0xFF2956CC)]),
        boxShadow: [BoxShadow(color: const Color(0xFF2972FF).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('20', style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                  Text('°C', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white70)),
                ]),
                const SizedBox(height: 8),
                Text('TP. Hồ Chí Minh, Việt Nam', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                const SizedBox(height: 4),
                Text('Hôm nay nhiều mây', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                Row(children: [
                  _weatherStat(CupertinoIcons.wind, 'AQI 92'),
                  const SizedBox(width: 12),
                  _weatherStat(CupertinoIcons.drop, '78.2%'),
                  const SizedBox(width: 12),
                  _weatherStat(CupertinoIcons.wind_snow, '2.0m/s'),
                ]),
              ],
            ),
          ),
          Positioned(right: 0, top: 10, bottom: 10, child: Image.asset('assets/images/icSunnyCloud.png', width: 140, fit: BoxFit.contain)),
        ],
      ),
    );
  }

  Widget _weatherStat(IconData icon, String label) {
    return Row(children: [
      Icon(icon, color: Colors.white70, size: 14),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildCategoryCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _categoryCard('Lightning', '${_devices.where((d) => d['name'].toString().toLowerCase().contains('lamp')).length} lights', Icons.lightbulb_outline, const Color(0xFFFFF7E6), const Color(0xFFFFA940)),
          const SizedBox(width: 16),
          _categoryCard('Cameras', '${_devices.where((d) => d['name'].toString().toLowerCase().contains('cctv') || d['name'].toString().toLowerCase().contains('webcam')).length} cameras', CupertinoIcons.videocam, const Color(0xFFF0F3FF), const Color(0xFF2972FF)),
          const SizedBox(width: 16),
          _categoryCard('Electrical', '${_devices.length} devices', Icons.power_outlined, const Color(0xFFFFF1F0), const Color(0xFFFF4D4F)),
        ],
      ),
    );
  }

  Widget _categoryCard(String title, String subtitle, IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 140, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 24)),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRoomFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _rooms.map((room) {
          final isSelected = room == _selectedRoom;
          return GestureDetector(
            onTap: () => setState(() => _selectedRoom = room),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2972FF) : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(room, style: GoogleFonts.outfit(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeviceGrid() {
    if (_devices.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Chưa có thiết bị nào")));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.0
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          final isCamera = device['isCamera'] == true || device['name'].toString().toLowerCase().contains('cctv') || device['name'].toString().toLowerCase().contains('webcam');
          
          if (isCamera) {
            return _deviceCardCamera(index, device['name'], device['image'] ?? 'assets/images/Smart_V1_CCTV.png', device['isOn'] ?? false);
          }
          return _deviceCard(index, device['name'], device['type'] ?? 'Wi-Fi', device['image'] ?? 'assets/images/Smart_Lamp.png', device['isOn'] ?? false);
        },
      ),
    );
  }

  Widget _deviceCard(int index, String name, String type, String imagePath, bool isOn) {
    return GestureDetector(
      onTap: () => _navigateToControl(_devices[index]),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.device_unknown, size: 60)),
                  const Spacer(),
                  Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type == 'Wi-Fi' ? Icons.wifi : Icons.bluetooth, size: 12, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(type, style: GoogleFonts.inter(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 8,
              child: Transform.scale(
                scale: 0.85, // To hơn xíu (từ 0.7 lên 0.85)
                child: CupertinoSwitch(
                  value: isOn,
                  activeColor: const Color(0xFF2972FF),
                  onChanged: (v) => _toggleDevice(index, v),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceCardCamera(int index, String name, String imagePath, bool isOn) {
    return GestureDetector(
      onTap: () => _navigateToControl(_devices[index]),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
             image: const AssetImage('assets/images/kitchenroom.jpg'), // Sử dụng ảnh kitchenroom.jpg như yêu cầu
             fit: BoxFit.cover,
             colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12, left: 12,
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('Live', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Positioned(
              top: 12, right: 8,
              child: Transform.scale(
                scale: 0.85, // To hơn xíu (từ 0.7 lên 0.85)
                child: CupertinoSwitch(
                  value: isOn,
                  activeColor: const Color(0xFF2972FF),
                  onChanged: (v) => _toggleDevice(index, v),
                ),
              ),
            ),
            Positioned(
              bottom: 12, left: 12, right: 12,
              child: Text(
                name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [const Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(0, 2))],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
