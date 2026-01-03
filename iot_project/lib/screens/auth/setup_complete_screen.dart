import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/theme.dart';

class SetupCompleteScreen extends StatelessWidget {
  const SetupCompleteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Central Illustration
            Stack(
              alignment: Alignment.center,
              children: [
                // Confetti dots
                _buildDot(-65, -45, 10),
                _buildDot(75, -35, 7),
                _buildDot(-45, 80, 6),
                _buildDot(35, 95, 5),
                _buildDot(85, 60, 5),
                _buildDot(-80, 30, 6),
                _buildDot(50, -80, 4),
                _buildDot(-30, -90, 3),
                
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              "Tuyệt vời!",
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Chúc mừng! Ngôi nhà của bạn hiện đã là một thiên đường Smartify. Hãy bắt đầu khám phá và quản lý không gian thông minh của bạn một cách dễ dàng.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF8E8E93),
                height: 1.6,
              ),
            ),
            const Spacer(flex: 3),
            // Bottom Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  "Bắt đầu ngay",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(double x, double y, double size) {
    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
