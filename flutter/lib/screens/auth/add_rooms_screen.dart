import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/theme.dart';

class AddRoomsScreen extends StatefulWidget {
  const AddRoomsScreen({Key? key}) : super(key: key);

  @override
  State<AddRoomsScreen> createState() => _AddRoomsScreenState();
}

class _AddRoomsScreenState extends State<AddRoomsScreen> {
  final Set<String> _selectedRooms = {'Phòng khách', 'Phòng ngủ', 'Phòng tắm', 'Nhà bếp', 'Phòng ăn', 'Sân sau'};

  final List<Map<String, dynamic>> _rooms = [
    {'name': 'Phòng khách', 'icon': Icons.weekend_outlined},
    {'name': 'Phòng ngủ', 'icon': Icons.bed_outlined},
    {'name': 'Phòng tắm', 'icon': Icons.bathtub_outlined},
    {'name': 'Nhà bếp', 'icon': Icons.restaurant_menu_outlined}, 
    {'name': 'Phòng học', 'icon': Icons.school_outlined},
    {'name': 'Phòng ăn', 'icon': Icons.restaurant_outlined},
    {'name': 'Sân sau', 'icon': Icons.deck_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: Color(0xFFF2F2F7),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "3 / 4",
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: "Thêm "),
                  TextSpan(
                    text: "Phòng",
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Chọn các phòng trong nhà của bạn. Đừng lo lắng, bạn luôn có thể thêm chúng sau.",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF8E8E93),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _rooms.length + 1,
                itemBuilder: (context, index) {
                  if (index == _rooms.length) {
                    return _buildAddRoomCard();
                  }
                  final room = _rooms[index];
                  final isSelected = _selectedRooms.contains(room['name']);
                  return _buildRoomCard(room, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/set_location');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F6FF),
                    foregroundColor: AppTheme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Bỏ qua"),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                    Navigator.pushNamed(
                      context, 
                      '/set_location',
                      arguments: {
                        'country': args?['country'],
                        'homeName': args?['homeName'],
                        'rooms': _selectedRooms.toList(),
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Tiếp tục"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedRooms.remove(room['name']);
          } else {
            _selectedRooms.add(room['name']);
          }
        });
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.5) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  room['icon'],
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  room['name'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddRoomCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor, width: 2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Thêm phòng",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
