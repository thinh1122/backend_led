import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:iot_project/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        // 1. Logo Section
                        Center(
                          child: ClipPath(
                            clipper: WelcomePentagonClipper(),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: AppTheme.primaryColor,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.wifi,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 60),

                        // 2. Welcome Texts
                        const Text(
                          "Chào Mừng Bạn!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Hãy bắt đầu trải nghiệm cùng tài khoản của bạn",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8E8E93),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 50),

                        // 3. Social Login Buttons
                        _SocialButton(
                          iconWidget: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                            width: 24,
                            height: 24,
                          ),
                          text: "Tiếp tục với Google",
                          onPressed: () {},
                        ),
                        const SizedBox(height: 16),
                        _SocialButton(
                          icon: Icons.apple,
                          text: "Tiếp tục với Apple",
                          onPressed: () {},
                          iconColor: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        _SocialButton(
                          icon: Icons.facebook,
                          text: "Tiếp tục với Facebook",
                          onPressed: () {},
                          iconColor: const Color(0xFF1877F2),
                        ),
                        const SizedBox(height: 16),
                        _SocialButton(
                          iconWidget: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Logo_of_Twitter.svg/1200px-Logo_of_Twitter.svg.png',
                            width: 24,
                            height: 24,
                          ),
                          text: "Tiếp tục với Twitter",
                          onPressed: () {},
                        ),

                        const SizedBox(height: 40),

                        // 4. Primary Actions
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2972FF),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Đăng ký",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F6FF),
                              foregroundColor: const Color(0xFF2972FF),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Đăng nhập",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 5. Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: const Text(
                                "Chính sách bảo mật",
                                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text("·", style: TextStyle(color: Color(0xFF8E8E93))),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: const Text(
                                "Điều khoản dịch vụ",
                                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String text;
  final VoidCallback onPressed;
  final Color? iconColor;

  const _SocialButton({
    this.icon,
    this.iconWidget,
    required this.text,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF2F2F7)), // Very light grey border
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          children: [
            if (iconWidget != null) iconWidget!,
            if (icon != null) Icon(icon, color: iconColor, size: 28),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 28), // Visual balance for the icon on the left
          ],
        ),
      ),
    );
  }
}

class WelcomePentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    List<Offset> points = [];
    double r = size.width / 2;
    double cx = size.width / 2;
    double cy = size.height / 2;
    for (int i = 0; i < 5; i++) {
      double angle = (math.pi / 2 * 3) + (i * 2 * math.pi / 5);
      points.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }
    double cornerRadius = size.width * 0.15;
    path.moveTo(points[0].dx, points[0].dy + cornerRadius);
    for (int i = 0; i < points.length; i++) {
        Offset current = points[i];
        Offset next = points[(i + 1) % points.length];
        Offset prev = points[(i - 1 + points.length) % points.length];
        Offset toPrev = prev - current;
        double distPrev = toPrev.distance;
        Offset start = current + toPrev * (cornerRadius / distPrev);
        Offset toNext = next - current;
        double distNext = toNext.distance;
        Offset end = current + toNext * (cornerRadius / distNext);
        if (i == 0) path.moveTo(start.dx, start.dy);
        else path.lineTo(start.dx, start.dy);
        path.quadraticBezierTo(current.dx, current.dy, end.dx, end.dy);
    }
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
