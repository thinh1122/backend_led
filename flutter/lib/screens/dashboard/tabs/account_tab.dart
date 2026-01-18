import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/account/home_management_screen.dart';
import 'package:iot_project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountTab extends StatefulWidget {
  final VoidCallback? onRefreshHome;
  const AccountTab({super.key, this.onRefreshHome});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final ApiService _apiService = ApiService();
  String _userEmail = '...';
  String _homeName = 'Nhà của tôi';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userEmail = prefs.getString('email') ?? 'User';
      });

      final response = await _apiService.getMyHouses();
      if (response.statusCode == 200 && response.data != null) {
        final List houses = response.data;
        if (houses.isNotEmpty) {
          setState(() {
            _homeName = houses[0]['name'] ?? 'Nhà của tôi';
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading account data: $e");
    }
  }

  void _showLogoutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 38,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Đăng xuất",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF75555),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Text(
                  "Bạn có chắc chắn muốn đăng xuất không?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEEF4FF),
                            foregroundColor: const Color(0xFF246BFD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            "Hủy",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('token');
                            await prefs.remove('email');
                            await prefs.remove('added_devices'); // Xóa cả thiết bị lưu cục bộ
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Đăng xuất thành công",
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF246BFD),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            "Đăng xuất",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Row(
              children: [
                Text(
                  _homeName,
                  style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 28),
                const Spacer(),
                const Icon(CupertinoIcons.viewfinder, size: 26),
                const SizedBox(width: 20),
                const Icon(Icons.more_vert, size: 26),
              ],
            ),
          ),

          // 2. Profile Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/avtAD.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userEmail.split('@')[0],
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userEmail,
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. General Section
          _buildSectionHeader('Chung'),
          _buildAccountListItem(CupertinoIcons.house, 'Quản lý nhà', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeManagementScreen(onUpdate: widget.onRefreshHome)));
          }),
          _buildAccountListItem(CupertinoIcons.mic, 'Trợ lý giọng nói', () {}),
          _buildAccountListItem(CupertinoIcons.bell, 'Thông báo', () {}),
          _buildAccountListItem(CupertinoIcons.shield, 'Tài khoản & Bảo mật', () {}),
          _buildAccountListItem(CupertinoIcons.arrow_up_arrow_down, 'Tài khoản liên kết', () {}),
          _buildAccountListItem(CupertinoIcons.eye, 'Giao diện ứng dụng', () {}),
          _buildAccountListItem(CupertinoIcons.settings, 'Cài đặt bổ sung', () {}),

          const SizedBox(height: 20),

          // 4. Support Section
          _buildSectionHeader('Hỗ trợ'),
          _buildAccountListItem(CupertinoIcons.graph_square, 'Dữ liệu & Phân tích', () {}),
          _buildAccountListItem(CupertinoIcons.doc_text, 'Trợ giúp & Hỗ trợ', () {}),

          // 5. Logout
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: _showLogoutDialog,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 26),
                    const SizedBox(width: 16),
                    Text(
                      'Đăng xuất',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(thickness: 0.8)),
        ],
      ),
    );
  }

  Widget _buildAccountListItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
