import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/account/create_home_screen.dart';
import 'package:iot_project/screens/account/edit_home_screen.dart';
import 'package:iot_project/services/api_service.dart';
import 'package:iot_project/theme.dart';

class HomeManagementScreen extends StatefulWidget {
  final VoidCallback? onUpdate;
  const HomeManagementScreen({super.key, this.onUpdate});

  @override
  State<HomeManagementScreen> createState() => _HomeManagementScreenState();
}

class _HomeManagementScreenState extends State<HomeManagementScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _houses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHouses();
  }

  Future<void> _fetchHouses() async {
    try {
      final response = await _apiService.getMyHouses();
      if (response.statusCode == 200) {
        setState(() {
          _houses = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
          'Quản lý nhà',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_houses.isEmpty)
                _buildEmptyState()
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _houses.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
                    itemBuilder: (context, index) {
                      final house = _houses[index];
                      return _buildHomeItem(context, house['name'] ?? "Không tên", house);
                    },
                  ),
                ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateHomeScreen()),
                    ).then((_) => _fetchHouses());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Tạo nhà mới',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.home_work_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Bạn chưa có ngôi nhà nào",
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeItem(BuildContext context, String title, dynamic house) {
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
      subtitle: Text("${house['rooms']?.length ?? 0} phòng"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditHomeScreen(
              house: house, 
              onUpdate: widget.onUpdate,
            ),
          ),
        ).then((_) => _fetchHouses());
      },
    );
  }
}
