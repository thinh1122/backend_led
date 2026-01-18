import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:iot_project/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print("SPLASH SCREEN STARTED"); // Debug log
    // Simulate loading time, then navigate to Onboarding
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo Section
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Icon Container with Rounded Pentagon Shape
                  ClipPath(
                    clipper: RoundedPentagonClipper(),
                    child: Container(
                      width: 120,
                      height: 120,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.wifi,
                        color: AppTheme.primaryColor,
                        size: 70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  Text(
                    "Smartify",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Loading Indicator at the bottom
            const Padding(
              padding: EdgeInsets.only(bottom: 48.0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoundedPentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    List<Offset> points = [];
    
    double r = size.width / 2;
    double cx = size.width / 2;
    double cy = size.height / 2; // Use center of bounding box
    // Adjust cy to centre the pentagon visually if needed, but geometric center is fine
    
    // Calculate vertices of a regular pentagon
    for (int i = 0; i < 5; i++) {
      double angle = (math.pi / 2 * 3) + (i * 2 * math.pi / 5);
      points.add(Offset(
        cx + r * math.cos(angle),
        cy + r * math.sin(angle),
      ));
    }

    // Draw the path with rounded corners
    double cornerRadius = size.width * 0.15; // Adjustable roundness

    path.moveTo(points[0].dx, points[0].dy + cornerRadius); // Start slightly below top vertex (not really accurate for rounding strategy)

    for (int i = 0; i < points.length; i++) {
        Offset current = points[i];
        Offset next = points[(i + 1) % points.length];
        Offset prev = points[(i - 1 + points.length) % points.length];
        
        // Vector from current to prev
        Offset toPrev = prev - current;
        double distPrev = toPrev.distance;
        Offset start = current + toPrev * (cornerRadius / distPrev);

        // Vector from current to next
        Offset toNext = next - current;
        double distNext = toNext.distance;
        Offset end = current + toNext * (cornerRadius / distNext);
        
        if (i == 0) {
            path.moveTo(start.dx, start.dy);
        } else {
            path.lineTo(start.dx, start.dy);
        }
        path.quadraticBezierTo(current.dx, current.dy, end.dx, end.dy);
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
