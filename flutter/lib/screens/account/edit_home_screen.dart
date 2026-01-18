import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/account/room_management_screen.dart';
import 'package:iot_project/screens/account/device_management_screen.dart';
import 'package:iot_project/theme.dart';

class EditHomeScreen extends StatefulWidget {
  final dynamic house;
  final VoidCallback? onUpdate; // Callback refresh Home
  const EditHomeScreen({super.key, required this.house, this.onUpdate});

  @override
  State<EditHomeScreen> createState() => _EditHomeScreenState();
}

class _EditHomeScreenState extends State<EditHomeScreen> {
  late String _homeName;
  late List<dynamic> _rooms;

  @override
  void initState() {
    super.initState();
    _homeName = widget.house['name'] ?? 'Nhà của tôi';
    _rooms = widget.house['rooms'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _homeName,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Section 1: Home Info
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoItem(
                    title: 'Tên nhà', 
                    value: _homeName,
                    onTap: () {
                      _showEditNameModal(context);
                    },
                  ),
                  _buildDivider(),
                  _buildInfoItem(
                    title: 'Quản lý phòng', 
                    value: '${_rooms.length} phòng',
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RoomManagementScreen(house: widget.house)),
                      );
                    }
                  ),
                  _buildDivider(),
                  _buildInfoItem(
                    title: 'Quản lý thiết bị', 
                    value: 'Xem chi tiết',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DeviceManagementScreen(
                          onDeviceChanged: widget.onUpdate, // Truyền callback
                        )),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildInfoItem(
                    title: 'Vị trí', 
                    value: widget.house['address'] ?? 'Chưa xác định', 
                    isLast: true
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Home Members
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thành viên nhà (1)',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMemberItem(
                    name: 'Bạn',
                    email: 'Chủ sở hữu',
                    role: 'Owner',
                    avatarAsset: 'assets/images/avtAD.jpg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Delete Home Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  // Implement delete logic here if needed
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF4D4F), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  foregroundColor: const Color(0xFFFF4D4F),
                  backgroundColor: const Color(0xFFFFF1F0).withOpacity(0.5),
                ),
                child: Text(
                  'Xóa nhà',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showEditNameModal(BuildContext context) {
    // Keeping UI only for now as per current complexity
  }

  Widget _buildInfoItem({required String title, required String value, bool isLast = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _buildMemberItem({
    required String name,
    required String email,
    required String role,
    String? avatarAsset,
    Color? color,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color ?? Colors.grey.shade300,
            image: avatarAsset != null
                ? DecorationImage(image: AssetImage(avatarAsset), fit: BoxFit.cover)
                : null,
          ),
          child: avatarAsset == null
              ? Center(child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          role,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
