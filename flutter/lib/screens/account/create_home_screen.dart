import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateHomeScreen extends StatefulWidget {
  const CreateHomeScreen({super.key});

  @override
  State<CreateHomeScreen> createState() => _CreateHomeScreenState();
}

class _CreateHomeScreenState extends State<CreateHomeScreen> {
  // Sample data for rooms selection
  final List<Map<String, dynamic>> _rooms = [
    {'name': 'Phòng khách', 'selected': true},
    {'name': 'Phòng ngủ', 'selected': true},
    {'name': 'Phòng tắm', 'selected': true},
    {'name': 'Phòng bếp', 'selected': false},
    {'name': 'Phòng học tập', 'selected': true},
    {'name': 'Phòng ăn', 'selected': false},
  ];

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
          'Tạo nhà mới',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Home Details
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tên nhà',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: TextEditingController(text: 'Nhà thuê của tôi'),
                            decoration: InputDecoration(
                              fillColor: const Color(0xFFF5F5F7),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          const SizedBox(height: 16),
                          // Location Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Vị trí',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Add Rooms
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Thêm phòng',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4263EB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          
                          // Room List
                           ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _rooms.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1, 
                              color: Color(0xFFF0F0F0),
                              indent: 20,
                              endIndent: 20,
                            ),
                            itemBuilder: (context, index) {
                              final room = _rooms[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                title: Text(
                                  room['name'],
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      room['selected'] = !room['selected'];
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: room['selected'] ? const Color(0xFF4263EB) : Colors.transparent,
                                      border: room['selected'] 
                                        ? null 
                                        : Border.all(color: Colors.grey.shade400, width: 2),
                                    ),
                                    child: room['selected']
                                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                                        : null,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    room['selected'] = !room['selected'];
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Save Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Save logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4263EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Lưu',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
