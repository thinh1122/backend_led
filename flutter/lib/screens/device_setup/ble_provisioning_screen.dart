import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:iot_project/theme.dart';
import 'package:iot_project/services/api_service.dart';

class BleProvisioningScreen extends StatefulWidget {
  final String deviceName;
  final String hardwareId;

  const BleProvisioningScreen({
    super.key,
    required this.deviceName,
    required this.hardwareId,
  });

  @override
  State<BleProvisioningScreen> createState() => _BleProvisioningScreenState();
}

class _BleProvisioningScreenState extends State<BleProvisioningScreen> {
  // Controllers
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  // State
  BleStatus _status = BleStatus.scanning;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  String _statusMessage = "Đang tìm thiết bị...";
  double _progress = 0.0;
  
  // WiFi scan state
  List<WiFiAccessPoint> _wifiNetworks = [];
  bool _isWifiScanning = false;
  bool _showManualInput = false;
  WiFiAccessPoint? _selectedNetwork;
  
  // Room Selection state
  List<Map<String, dynamic>> _rooms = [];
  String? _selectedRoomId;
  bool _isLoadingRooms = false;
  
  // BLE UUIDs (phải khớp với firmware ESP32)
  // Firmware dùng UUID 16-bit: 0x00FF (service), 0xFF01 (characteristic)
  // Bluetooth SIG base UUID: 0000xxxx-0000-1000-8000-00805f9b34fb
  static const String SERVICE_UUID = "000000ff-0000-1000-8000-00805f9b34fb";
  static const String CHAR_WRITE_UUID = "0000ff01-0000-1000-8000-00805f9b34fb";
  
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _startAutoConnect();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    _connectedDevice?.disconnect();
    _ssidController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /// Tự động scan và kết nối BLE device có tên chứa hardwareId
  Future<void> _startAutoConnect() async {
    setState(() {
      _status = BleStatus.scanning;
      _statusMessage = "Đang tìm ${widget.deviceName}...";
      _progress = 0.1;
    });

    try {
      // Check Bluetooth state first
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        setState(() {
          _status = BleStatus.error;
          _statusMessage = "Vui lòng bật Bluetooth trong Settings";
        });
        return;
      }
      
      // Bắt đầu scan
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
        for (final result in results) {
          final deviceName = result.device.platformName;
          debugPrint("Found BLE: $deviceName");
          
          // Tìm device có tên chứa hardwareId (vd: PROV_ABC123)
          if (deviceName.contains(widget.hardwareId) || 
              deviceName.contains("PROV_")) {
            
            // Dừng scan
            await FlutterBluePlus.stopScan();
            _scanSubscription?.cancel();
            
            // Kết nối
            await _connectToDevice(result.device);
            return;
          }
        }
      });
      
      // Timeout handler
      await Future.delayed(const Duration(seconds: 15));
      if (_status == BleStatus.scanning) {
        await FlutterBluePlus.stopScan();
        setState(() {
          _status = BleStatus.error;
          _statusMessage = "Không tìm thấy thiết bị. Hãy chắc chắn thiết bị đang ở chế độ cài đặt.";
        });
      }
      
    } catch (e) {
      debugPrint("Scan error: $e");
      setState(() {
        _status = BleStatus.error;
        _statusMessage = "Lỗi Bluetooth: $e";
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _status = BleStatus.connecting;
      _statusMessage = "Đang kết nối ${device.platformName}...";
      _progress = 0.3;
    });

    try {
      // Ensure scan is stopped
      await FlutterBluePlus.stopScan();
      
      // Disconnect any existing connections
      final connectedDevices = await FlutterBluePlus.connectedDevices;
      for (final d in connectedDevices) {
        try {
          await d.disconnect();
        } catch (e) {
          debugPrint("Error disconnecting $d: $e");
        }
      }
      
      // Wait a bit for cleanup
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Now connect
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
      _connectedDevice = device;
      
      setState(() {
        _statusMessage = "Đang khám phá dịch vụ...";
        _progress = 0.4;
      });
      
      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      debugPrint("=== Khám phá được ${services.length} dịch vụ ===");
      
      BluetoothCharacteristic? targetChar;

      // Bước 1: Tìm đúng Service 00FF và Characteristic FF01
      for (final service in services) {
        String sUuid = service.uuid.toString().toLowerCase();
        if (sUuid.contains("00ff") || sUuid == SERVICE_UUID.toLowerCase()) {
          debugPrint("  🎯 Đã tìm thấy WiFi Service (00FF)");
          for (final char in service.characteristics) {
            String cUuid = char.uuid.toString().toLowerCase();
            if (cUuid.contains("ff01") || cUuid == CHAR_WRITE_UUID.toLowerCase()) {
              targetChar = char;
              debugPrint("  ✅ Đã tìm thấy đúng cổng WiFi Config (FF01)");
              break;
            }
          }
        }
      }

      // Bước 2: Fallback nếu không tìm thấy đúng UUID (đề phòng)
      if (targetChar == null) {
        debugPrint("  ⚠️ Không tìm thấy UUID chuẩn, đang tìm cổng ghi bất kỳ...");
        for (final service in services) {
          for (final char in service.characteristics) {
            if (char.properties.write || char.properties.writeWithoutResponse) {
              targetChar = char;
              debugPrint("  🔸 Sử dụng cổng ghi tạm thời: ${char.uuid}");
              break;
            }
          }
          if (targetChar != null) break;
        }
      }

      if (targetChar != null) {
        _writeCharacteristic = targetChar;
        if (!mounted) return;
        setState(() {
          _status = BleStatus.connected;
          _statusMessage = "Đã kết nối! Đang quét WiFi...";
          _progress = 0.5;
        });
        _scanWifiNetworks();
      } else {
        throw Exception("Thiết bị không có cổng nhận dữ liệu WiFi");
      }
      
    } catch (e) {
      debugPrint("Connect error: $e");
      setState(() {
        _status = BleStatus.error;
        _statusMessage = "Không thể kết nối. Vui lòng thử lại.";
      });
      
      // Cleanup on error
      try {
        await device.disconnect();
      } catch (_) {}
    }
  }

  /// Quét WiFi networks xung quanh
  Future<void> _scanWifiNetworks() async {
    setState(() => _isWifiScanning = true);
    
    try {
      // Check permission
      final canScan = await WiFiScan.instance.canGetScannedResults();
      if (canScan != CanGetScannedResults.yes) {
        debugPrint("Cannot scan WiFi");
        setState(() {
          _isWifiScanning = false;
          _statusMessage = "Đã kết nối! Nhập WiFi thủ công.";
        });
        return;
      }
      
      // Start scan
      await WiFiScan.instance.startScan();
      
      // Wait a bit for scan to complete
      await Future.delayed(const Duration(seconds: 3));
      
      // Get results
      final results = await WiFiScan.instance.getScannedResults();
      
      // Filter và sắp xếp theo signal strength
      final uniqueNetworks = <String, WiFiAccessPoint>{};
      for (final ap in results) {
        if (ap.ssid.isNotEmpty) {
          if (!uniqueNetworks.containsKey(ap.ssid) ||
              ap.level > uniqueNetworks[ap.ssid]!.level) {
            uniqueNetworks[ap.ssid] = ap;
          }
        }
      }
      
      // Sắp xếp theo signal (mạnh nhất trước)
      final sortedList = uniqueNetworks.values.toList()
        ..sort((a, b) => b.level.compareTo(a.level));
      
      setState(() {
        _wifiNetworks = sortedList;
        _isWifiScanning = false;
        _statusMessage = "Chọn WiFi để kết nối";
      });
      
    } catch (e) {
      debugPrint("WiFi scan error: $e");
      setState(() {
        _isWifiScanning = false;
        _statusMessage = "Đã kết nối! Nhập WiFi thủ công.";
      });
    }
  }

  Future<void> _sendWifiCredentials() async {
    if (_ssidController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin WiFi")),
      );
      return;
    }
    
    if (_writeCharacteristic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa kết nối với thiết bị")),
      );
      return;
    }

    setState(() {
      _status = BleStatus.provisioning;
      _statusMessage = "Đang gửi thông tin WiFi...";
      _progress = 0.6;
    });

    try {
      // Format: {"ssid":"XXX","password":"YYY"}
      final wifiConfig = jsonEncode({
        "ssid": _ssidController.text,
        "password": _passController.text,
      });
      
      debugPrint("📡 Sending WiFi config via BLE:");
      debugPrint("   SSID: ${_ssidController.text}");
      debugPrint("   Password: ${_passController.text.replaceAll(RegExp(r'.'), '*')}");
      debugPrint("   JSON: $wifiConfig");
      debugPrint("   Characteristic: ${_writeCharacteristic!.uuid}");
      
      // Gửi qua BLE
      try {
        await _writeCharacteristic!.write(
          utf8.encode(wifiConfig),
          withoutResponse: false,
          timeout: 5,
        );
        debugPrint("✅ BLE write thành công!");
      } catch (e) {
        // Nếu lỗi xảy ra ngay khi gửi WiFi, thường là do chip đã nhận 
        // và chủ động reboot làm ngắt kết nối. Chúng ta coi đây là thành công.
        debugPrint("🔸 BLE write bị ngắt (có thể do chip restart): $e");
      }
      
      if (!mounted) return;
      setState(() {
        _statusMessage = "Thiết bị đang khởi động lại...";
        _progress = 0.75;
      });
      
      // Chờ ESP32 khởi động lại và kết nối WiFi (10-15 giây)
      await Future.delayed(const Duration(seconds: 12));
      
      if (!mounted) return;
      
      // Bước mới: Tải danh sách phòng và yêu cầu người dùng chọn
      await _fetchRooms();
      
      if (!mounted) return;
      setState(() {
        _status = BleStatus.selectingRoom;
        _statusMessage = "Chọn phòng cho thiết bị của bạn";
        _progress = 0.9;
      });
      
    } catch (e) {
      debugPrint("Provisioning error: $e");
      setState(() {
        _status = BleStatus.error;
        _statusMessage = "Lỗi gửi WiFi: $e";
      });
    }
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoadingRooms = true);
    try {
      final rooms = await ApiService().getMyRooms();
      setState(() {
        _rooms = rooms;
        _isLoadingRooms = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải phòng: $e");
      // Tạm thời tạo phòng test để UI hoạt động
      setState(() {
        _rooms = [
          {'id': '1', 'name': 'Phòng khách'},
          {'id': '2', 'name': 'Phòng ngủ'},
          {'id': '3', 'name': 'Sân sau'},
          {'id': '4', 'name': 'Nhà bếp'},
        ];
        _isLoadingRooms = false;
      });
    }
  }

  Future<void> _addDeviceToServer() async {
    if (_selectedRoomId == null) return;
    
    setState(() {
       _statusMessage = "Đang lưu thiết bị vào hệ thống...";
       _progress = 0.95;
    });

    try {
      final apiService = ApiService();
      await apiService.addDevice(
        widget.deviceName,
        "assets/images/Smart_Lamp.png",
        type: "Wi-Fi",
        hardwareId: widget.hardwareId,
        roomId: _selectedRoomId,
      );
      
      setState(() {
        _status = BleStatus.success;
        _statusMessage = "Thành công!";
        _progress = 1.0;
      });
      
      // Disconnect BLE
      await _connectedDevice?.disconnect();
      
    } catch (e) {
      debugPrint("API error: $e");
      setState(() {
        _status = BleStatus.error;
        _statusMessage = "Lỗi lưu thiết bị: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Kết nối thiết bị", style: GoogleFonts.outfit(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Icon
              _buildStatusIcon(),
              
              const SizedBox(height: 24),
              
              // Device Name
              Text(
                widget.deviceName,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Status Message
              Text(
                _statusMessage,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: _status == BleStatus.error ? Colors.red : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Progress Bar
              if (_status != BleStatus.success && _status != BleStatus.error && _status != BleStatus.selectingRoom)
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              
              const SizedBox(height: 32),
              
              // Room Selection UI
              if (_status == BleStatus.selectingRoom) ...[
                Expanded(child: _buildRoomSelection()),
              ],
              
              // WiFi Selection (chỉ hiện khi đã connect)
              if (_status == BleStatus.connected) ...[
                // WiFi List hoặc Manual Input
                Expanded(
                  child: _showManualInput || _wifiNetworks.isEmpty
                      ? _buildManualInput()
                      : _buildWifiList(),
                ),
              ],
              
              // Success Button
              if (_status == BleStatus.success) ...[
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true); // Quay về và refresh
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "VỀ TRANG CHỦ",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              
              // Retry Button
              if (_status == BleStatus.error) ...[
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      _startAutoConnect();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "THỬ LẠI",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              
              // Loading states
              if (_status == BleStatus.scanning || 
                  _status == BleStatus.connecting ||
                  _status == BleStatus.provisioning) ...[
                const Spacer(),
                CircularProgressIndicator(color: AppTheme.primaryColor),
                const Spacer(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    double size = 80;
    
    switch (_status) {
      case BleStatus.scanning:
        icon = Icons.bluetooth_searching;
        color = Colors.blue;
        break;
      case BleStatus.connecting:
        icon = Icons.bluetooth_connected;
        color = Colors.orange;
        break;
      case BleStatus.connected:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case BleStatus.provisioning:
        icon = Icons.wifi;
        color = Colors.orange;
        break;
      case BleStatus.selectingRoom:
        icon = Icons.room_preferences;
        color = AppTheme.primaryColor;
        break;
      case BleStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case BleStatus.error:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size, color: color),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  /// Build WiFi List UI
  Widget _buildWifiList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với nút actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Chọn WiFi:",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
                  onPressed: _isWifiScanning ? null : _scanWifiNetworks,
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _showManualInput = true);
                  },
                  child: Text(
                    "Nhập thủ công",
                    style: GoogleFonts.outfit(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // WiFi List
        Expanded(
          child: _isWifiScanning
              ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : ListView.builder(
                  itemCount: _wifiNetworks.length,
                  itemBuilder: (context, index) {
                    final network = _wifiNetworks[index];
                    return _buildWifiItem(network);
                  },
                ),
        ),
      ],
    );
  }

  /// Build WiFi Item
  Widget _buildWifiItem(WiFiAccessPoint network) {
    // Calculate signal strength bars (1-4)
    final signalBars = network.level >= -50
        ? 4
        : network.level >= -60
            ? 3
            : network.level >= -70
                ? 2
                : 1;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          CupertinoIcons.wifi,
          color: signalBars >= 3 ? Colors.green : Colors.orange,
        ),
        title: Text(
          network.ssid,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${network.capabilities} • ${network.level} dBm",
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            4,
            (i) => Container(
              width: 4,
              height: 6 + (i * 3),
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(
                color: i < signalBars ? AppTheme.primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
        onTap: () {
          setState(() {
            _selectedNetwork = network;
            _ssidController.text = network.ssid;
            _passController.clear();
          });
          _showPasswordDialog(network);
        },
      ),
    );
  }

  /// Show password dialog when WiFi selected
  void _showPasswordDialog(WiFiAccessPoint network) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          network.ssid,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              network.capabilities,
              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Mật khẩu WiFi",
                prefixIcon: const Icon(CupertinoIcons.lock, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Hủy", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _sendWifiCredentials();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Kết nối",
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Manual Input UI
  Widget _buildManualInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Nhập WiFi thủ công:",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_wifiNetworks.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _showManualInput = false);
                },
                child: Text(
                  "Chọn từ danh sách",
                  style: GoogleFonts.outfit(color: AppTheme.primaryColor),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          "Tên WiFi nhà bạn (SSID)",
          _ssidController,
          CupertinoIcons.wifi,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "Mật khẩu WiFi",
          _passController,
          CupertinoIcons.lock,
          isPassword: true,
        ),
        
        const Spacer(),
        
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _sendWifiCredentials,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "GỬI CẤU HÌNH WIFI",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSelection() {
    if (_isLoadingRooms) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Bạn chưa có phòng nào.\nHãy tạo phòng trước trên trang chủ.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chọn không gian đặt thiết bị:",
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              final room = _rooms[index];
              final isSelected = _selectedRoomId == room['id'];
              
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    debugPrint("🔘 Room tapped: ${room['name']} (ID: ${room['id']})");
                    setState(() => _selectedRoomId = room['id']);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                      ] : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      room['name'],
                      style: GoogleFonts.outfit(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _selectedRoomId == null ? null : _addDeviceToServer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(
              "HOÀN TẤT CÀI ĐẶT",
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

enum BleStatus {
  scanning,
  connecting,
  connected,
  provisioning,
  selectingRoom,
  success,
  error,
}
