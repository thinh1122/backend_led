import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/theme.dart';

class AddHomeNameScreen extends StatefulWidget {
  const AddHomeNameScreen({Key? key}) : super(key: key);

  @override
  State<AddHomeNameScreen> createState() => _AddHomeNameScreenState();
}

class _AddHomeNameScreenState extends State<AddHomeNameScreen> {
  final TextEditingController _homeNameController = TextEditingController(text: "Nhà của tôi");

  @override
  void dispose() {
    _homeNameController.dispose();
    super.dispose();
  }

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
                  value: 0.5,
                  backgroundColor: Color(0xFFF2F2F7),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "2 / 4",
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
                  const TextSpan(text: "Đặt tên "),
                  TextSpan(
                    text: "Nhà ",
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                  const TextSpan(text: "của bạn"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Mỗi ngôi nhà thông minh đều cần một cái tên. Bạn muốn gọi ngôi nhà của mình là gì?",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF8E8E93),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Home Name Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _homeNameController,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: "Nhập tên nhà...",
                  hintStyle: TextStyle(color: Color(0xFFC7C7CC)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                ),
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
                    Navigator.pushNamed(context, '/add_rooms');
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
                    final homeName = _homeNameController.text.trim();
                    Navigator.pushNamed(
                      context, 
                      '/add_rooms',
                      arguments: {
                        'country': args?['country'],
                        'homeName': homeName.isNotEmpty ? homeName : "Nhà của tôi",
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
}
