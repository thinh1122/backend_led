import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/theme.dart';
import 'package:iot_project/services/api_service.dart';
import 'package:iot_project/services/mqtt_service.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final MqttService _mqttService = MqttService();
  
  bool _isOn = false;
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDeviceState();
    _loadSchedules();
    _setupMqttListener();
  }

  void _setupMqttListener() {
    _mqttService.connect();
    // Lắng nghe trạng thái thiết bị
    _mqttService.subscribeToTopic('smarthome/devices/${widget.device['hardwareId']}/state');
  }

  Future<void> _loadDeviceState() async {
    // TODO: Load trạng thái thiết bị từ MQTT hoặc API
    setState(() {
      _isOn = widget.device['state'] == 'ON';
    });
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    try {
      final schedules = await _apiService.getSchedulesByDevice(widget.device['id']);
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải lịch hẹn: $e')),
        );
      }
    }
  }

  Future<void> _toggleDevice() async {
    final newState = !_isOn;
    setState(() => _isOn = newState);
    
    // Gửi lệnh qua MQTT
    _mqttService.publishMessage(
      'smarthome/devices/${widget.device['hardwareId']}/set',
      newState ? 'ON' : 'OFF',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.device['name'] ?? 'Thiết bị',
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Điều khiển'),
            Tab(text: 'Hẹn giờ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildControlTab(),
          _buildScheduleTab(),
        ],
      ),
    );
  }

  Widget _buildControlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Card thiết bị
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon thiết bị
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _isOn ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    size: 60,
                    color: _isOn ? AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Tên thiết bị
                Text(
                  widget.device['name'] ?? 'Thiết bị',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Trạng thái
                Text(
                  _isOn ? 'Đang bật' : 'Đang tắt',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: _isOn ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Nút bật/tắt
                GestureDetector(
                  onTap: _toggleDevice,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isOn
                            ? [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)]
                            : [Colors.grey[400]!, Colors.grey[300]!],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: (_isOn ? AppTheme.primaryColor : Colors.grey).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isOn ? 'TẮT' : 'BẬT',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Thông tin thiết bị
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Loại', widget.device['type'] ?? 'Wi-Fi'),
                _buildInfoRow('Phòng', widget.device['roomName'] ?? 'Chưa xác định'),
                _buildInfoRow('Hardware ID', widget.device['hardwareId'] ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _schedules.isEmpty
                  ? _buildEmptySchedule()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _schedules.length,
                      itemBuilder: (context, index) {
                        return _buildScheduleCard(_schedules[index]);
                      },
                    ),
        ),
        
        // Nút thêm lịch hẹn
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => _showAddScheduleDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Thêm lịch hẹn',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySchedule() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch hẹn nào',
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bấm nút bên dưới để thêm',
            style: GoogleFonts.outfit(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final time = schedule['time'] ?? '00:00';
    final action = schedule['action'] ?? 'ON';
    final enabled = schedule['enabled'] ?? true;
    final name = schedule['name'] ?? 'Lịch hẹn';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: enabled ? AppTheme.primaryColor.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (action == 'ON' ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              action == 'ON' ? Icons.power_settings_new : Icons.power_off,
              color: action == 'ON' ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          
          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$time - ${action == 'ON' ? 'Bật' : 'Tắt'}',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Switch
          Switch(
            value: enabled,
            onChanged: (value) => _toggleSchedule(schedule['id'], value),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddScheduleDialog() async {
    TimeOfDay? selectedTime = TimeOfDay.now();
    String selectedAction = 'ON';
    String scheduleName = '';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Thêm lịch hẹn', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tên lịch hẹn
              TextField(
                decoration: InputDecoration(
                  labelText: 'Tên lịch hẹn',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) => scheduleName = value,
              ),
              const SizedBox(height: 16),
              
              // Chọn giờ
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('Giờ: ${selectedTime?.format(context)}'),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime!,
                  );
                  if (time != null) {
                    setDialogState(() => selectedTime = time);
                  }
                },
              ),
              
              // Chọn hành động
              ListTile(
                leading: const Icon(Icons.power_settings_new),
                title: const Text('Hành động'),
                trailing: DropdownButton<String>(
                  value: selectedAction,
                  items: const [
                    DropdownMenuItem(value: 'ON', child: Text('Bật')),
                    DropdownMenuItem(value: 'OFF', child: Text('Tắt')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedAction = value);
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (scheduleName.isEmpty) {
                  scheduleName = '${selectedAction == 'ON' ? 'Bật' : 'Tắt'} lúc ${selectedTime?.format(context)}';
                }
                await _createSchedule(selectedTime!, selectedAction, scheduleName);
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Thêm', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSchedule(TimeOfDay time, String action, String name) async {
    try {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      await _apiService.createSchedule(
        deviceId: widget.device['id'],
        time: timeString,
        action: action,
        name: name,
      );
      await _loadSchedules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm lịch hẹn')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _toggleSchedule(int scheduleId, bool enabled) async {
    try {
      await _apiService.updateSchedule(scheduleId, enabled: enabled);
      await _loadSchedules();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}
