import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  late PageController _imagePageController;
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Nâng Tầm Ngôi Nhà,\nĐơn Giản Hoá Cuộc Sống",
      "description": "Biến không gian sống của bạn thành một ngôi nhà thông minh, kết nối hơn với Smartify. Tất cả trong tầm tay bạn.",
      "image": "assets/images/img1.png"
    },
    {
      "title": "Điều Khiển Dễ Dàng,\nTự Động & Bảo Mật",
      "description": "Smartify cho phép bạn điều khiển thiết bị và tự động hóa các thói quen. Tận hưởng thế giới nơi ngôi nhà thích nghi với nhu cầu của bạn.",
      "image": "assets/images/img2.png"
    },
    {
      "title": "Tiết Kiệm Hiệu Quả,\nThoải Mái Bền Lâu",
      "description": "Kiểm soát mức sử dụng năng lượng, thiết lập sở thích và tận hưởng không gian sống lý tưởng của riêng bạn.",
      "image": "assets/images/img3.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _imagePageController = PageController();

    // Sync image scroll with text scroll
    _pageController.addListener(() {
      if (_imagePageController.hasClients) {
        _imagePageController.jumpTo(_pageController.offset);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFF2972FF), // Blue background
      body: Stack(
        children: [
          // 1. Layer 1: Images (Behind the white curve)
          Positioned.fill(
            child: PageView.builder(
              controller: _imagePageController,
              itemCount: _onboardingData.length,
              physics: const NeverScrollableScrollPhysics(), // Disable direct swipe on image, driven by text layer
              itemBuilder: (context, index) {
                 return Column(
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: [
                     const SizedBox(height: 100), // Đẩy ảnh xuống thấp để bị che bớt
                     
                     // Image Container
                     Container(
                       height: screenHeight * 0.60, // Ảnh to hơn nữa
                       margin: const EdgeInsets.symmetric(horizontal: 10), // Reduced margin to make it look bigger
                       child: _onboardingData[index]["image"] != null 
                           ? Image.asset(
                               _onboardingData[index]["image"]!,
                               fit: BoxFit.contain, 
                               alignment: Alignment.bottomCenter, 
                             ) 
                           : const SizedBox(), 
                     ),
                     const Spacer(),
                   ],
                 );
              }
            ),
          ),

          // 2. Layer 2: White Curved Bottom Background
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                height: screenHeight * 0.48, // Nâng cao phần trắng lên
                color: Colors.white,
              ),
            ),
          ),
          
          // 3. Layer 3: Text Content (On top of white curve)
          // Transparency allows seeing the image behind top part, but swipes work everywhere
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                 return Column(
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: [
                     // Invisible spacer matching Image area
                     SizedBox(height: screenHeight * 0.59), // Text nằm thấp hơn nữa (0.56 -> 0.59)
                     
                     const SizedBox(height: 10), // Khoảng cách nhỏ

                     // Text Content
                     Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            Text(
                              _onboardingData[index]["title"]!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, 
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _onboardingData[index]["description"]!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8E8E93), 
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3, 
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Reserve space for bottom controls
                      const SizedBox(height: 100), 
                   ],
                 );
              }
            ),
          ),

          // 4. Layer 4: Static Controls (Dots & Buttons)
          Column(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
              // Dot Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: _currentPage == index ? 24 : 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF2972FF)
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 36.0),
                child: _currentPage == _onboardingData.length - 1
                    ? SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                             Navigator.pushReplacementNamed(context, '/welcome');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2972FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Bắt đầu ngay",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: TextButton(
                                onPressed: () {
                                   Navigator.pushReplacementNamed(context, '/welcome');
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFF3F6FF), 
                                  foregroundColor: const Color(0xFF2972FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: const Text(
                                  "Bỏ qua",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2972FF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Tiếp tục",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
             ],
          )
        ],
      ),
    );
  }
}

// Clipper for the concave curve (Valley) - White area dips in the middle
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // Start at Top Left (0, 0) - high point
    path.moveTo(0, 0); 
    
    // Curve DOWN to the center and then UP to Top Right
    // Control point at (width/2, 90) means the curve dips clearer/deeper.
    path.quadraticBezierTo(size.width / 2, 90, size.width, 0);
    
    // Continue to Bottom Right
    path.lineTo(size.width, size.height);
    
    // Continue to Bottom Left
    path.lineTo(0, size.height);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
