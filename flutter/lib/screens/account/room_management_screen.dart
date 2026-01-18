import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/account/manage_rooms_screen.dart';

class RoomManagementScreen extends StatefulWidget {
  final dynamic house;
  const RoomManagementScreen({super.key, this.house});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  late List<dynamic> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = widget.house?['rooms'] ?? [];
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
          'Quản lý phòng',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(CupertinoIcons.square_grid_2x2, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageRoomsScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (_rooms.isEmpty)
                const Expanded(child: Center(child: Text("Bấm 'Thêm phòng' để bắt đầu")))
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rooms.length,
                    separatorBuilder: (context, index) => _buildDivider(),
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return _buildRoomItem(room['name'] ?? "Phòng không tên");
                    },
                  ),
                ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                onPressed: () {
                    // Chức năng thêm phòng thực tế sẽ được cập nhật sau
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4263EB), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    foregroundColor: const Color(0xFF4263EB),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    'Thêm phòng',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomItem(String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      onTap: () {},
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
}
