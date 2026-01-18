import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ControlDeviceScreen extends StatefulWidget {
  final String deviceName;
  final String deviceImage;

  const ControlDeviceScreen({
    super.key,
    this.deviceName = 'Smart Lamp',
    this.deviceImage = 'assets/images/Smart_Lamp.png',
  });

  @override
  State<ControlDeviceScreen> createState() => _ControlDeviceScreenState();
}

class _ControlDeviceScreenState extends State<ControlDeviceScreen> {
  bool _isDeviceOn = true;
  int _selectedTab = 0; // 0: White, 1: Color, 2: Scene
  int _acTab = 0; // 0: Cooling, 1: Heating, 2: Purifying
  double _brightness = 85;
  double _temperature = 0.2; // 0.0 to 1.0 (Warm to Cool)
  double _hue = 0.0; // 0.0 to 360.0
  double _intensity = 64; // Contrast/Intensity slider
  double _volume = 65; // Volume for Speaker
  double _acTemp = 20; // AC Temperature


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Điều khiển thiết bị',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: _buildDeviceControl(),
      ),
    );
  }

  Widget _buildDeviceControl() {
    if (widget.deviceName.contains('CCTV') || widget.deviceName.contains('Webcam')) {
      return _buildCCTVControl();
    } else if (widget.deviceName == 'Smart Speaker' || widget.deviceName == 'Loa Thông minh') {
      return _buildSpeakerControl();
    } else if (widget.deviceName == 'Air Conditioner' || widget.deviceName == 'Máy điều hòa') {
      return _buildACControl();
    } else {
      return _buildLampControl();
    }
  }

  Widget _buildACControl() {
    return Column(
      children: [
        const SizedBox(height: 10),
        
        // Device Info & Toggle (Header)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(4),
                child: Image.asset(widget.deviceImage),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Máy điều hòa',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phòng khách',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Switch
              Transform.scale(
                scale: 1.2,
                child: CupertinoSwitch(
                  value: _isDeviceOn,
                  onChanged: (v) => setState(() => _isDeviceOn = v),
                  activeColor: const Color(0xFF2962FF),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),

        // Tabs (Cooling, Heating, Purifying)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildACTabItem('Làm mát', 0),
              _buildACTabItem('Sưởi ấm', 1),
              _buildACTabItem('Lọc không khí', 2),
            ],
          ),
        ),
        
        const Spacer(),

        // AC Temp Control (Reusing layout style)
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            // Custom Volume Painter (Reused for AC Temp)
            CustomPaint(
              size: const Size(360, 360), // Increased from 340
              painter: VolumeArcPainter(
                value: (_acTemp - 16) / (30 - 16), // Map 16-30 range to 0-1
              ),
            ),
            
            // Percentage Text
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_acTemp.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          '°C',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                   Text(
                     'Nhiệt độ',
                     style: GoogleFonts.inter(
                       fontSize: 18,
                       color: Colors.grey.shade500,
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),

        const Spacer(),
        
        // Functions Grid
        SizedBox(
          height: 190, // Reduced from 220 to save space
          child: GridView.count(
            crossAxisCount: 4,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, // Reduced spacing
            children: [
              _buildFeatureItemAC(Icons.tune, 'Chế độ'),
              _buildFeatureItemAC(Icons.air, 'Tốc độ gió'),
              _buildFeatureItemAC(Icons.swap_vert, 'Hướng gió'), // Approximation
              _buildFeatureItemAC(Icons.gps_fixed, 'Gió chính xác'),
              _buildFeatureItemAC(Icons.eco, 'Tiết kiệm'),
              _buildFeatureItemAC(Icons.nightlight_round, 'Ngủ'),
              _buildFeatureItemAC(Icons.timer, 'Hẹn giờ'),
              _buildFeatureItemAC(Icons.grid_view, 'Thêm'),
            ],
          ),
        ),

        const SizedBox(height: 12), // Reduced from 24

         // Bottom Button
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 24.0),
           child: SizedBox(
             width: double.infinity,
             height: 56,
             child: ElevatedButton(
               onPressed: () {},
               style: ElevatedButton.styleFrom(
                 backgroundColor: const Color(0xFFEBEFFF), // Light Blue
                 foregroundColor: const Color(0xFF2962FF),
                 elevation: 0,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(30),
                 ),
               ),
               child: Text(
                 'Lên lịch Bật/Tắt & Cảnh thông minh',
                 style: GoogleFonts.inter(
                   fontSize: 14,
                   fontWeight: FontWeight.w600,
                 ),
               ),
             ),
           ),
         ),

        const SizedBox(height: 20), // Reduced from 30
      ],
    );
  }

  Widget _buildSpeakerControl() {
    return Column(
      children: [
        const SizedBox(height: 10),
        
        // Device Info & Toggle (Header)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(4),
                child: Image.asset(widget.deviceImage),
              ),
              const SizedBox(width: 16),
              // Text and Switch same as Lamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loa Stereo', // User requested name change in control UI
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phòng khách',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.2,
                child: CupertinoSwitch(
                  value: _isDeviceOn,
                  onChanged: (v) => setState(() => _isDeviceOn = v),
                  activeColor: const Color(0xFF2962FF),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Music Player Card
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(30),
          ),
              child: Row(
            mainAxisSize: MainAxisSize.min, // Center the content
            children: [
               // Spotify-like Icon
               Container(
                 width: 24,
                 height: 24,
                 decoration: const BoxDecoration(
                   color: Color(0xFF1DB954), // Spotify Green
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(Icons.music_note, color: Colors.white, size: 16),
               ),
               const SizedBox(width: 12),

               Expanded(
                 child: Text(
                   'Ed Sheeran - Shape of You',
                   overflow: TextOverflow.ellipsis,
                   style: GoogleFonts.inter(
                     fontSize: 14,
                     color: Colors.grey.shade700,
                   ),
                 ),
               ),
            ],
          ),
        ),

        const Spacer(),

        // Circular Volume Control
        Stack(
          alignment: Alignment.center,
          children: [
            // Custom Volume Painter
            CustomPaint(
              size: const Size(360, 360),
              painter: VolumeArcPainter(
                value: _volume / 100,
              ),
            ),
            
            // Percentage Text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_volume.toInt()}',
                      style: GoogleFonts.outfit(
                        fontSize: 76,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '%',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                 Text(
                   'Âm lượng',
                   style: GoogleFonts.inter(
                     fontSize: 16,
                     color: Colors.grey.shade500,
                   ),
                 ),
              ],
            ),
          ],
        ),

        const Spacer(),

        // Playback Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(Icons.skip_previous, size: 48, color: const Color(0xFFF5F5F5), iconColor: const Color(0xFF2962FF)),
             const SizedBox(width: 32),
             _buildCircleButton(Icons.pause, size: 72, color: const Color(0xFF2962FF), iconColor: Colors.white),
             const SizedBox(width: 32),
             _buildCircleButton(Icons.skip_next, size: 48, color: const Color(0xFFF5F5F5), iconColor: const Color(0xFF2962FF)),
          ],
        ),
        
        const SizedBox(height: 40),

        // Bottom Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Theme(
                 data: ThemeData(
                   sliderTheme: SliderThemeData(
                     trackHeight: 6,
                     activeTrackColor: const Color(0xFF2962FF),
                     inactiveTrackColor: Colors.grey.shade100,
                     thumbColor: Colors.white,
                     thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
                     overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                      trackShape: const RoundedRectSliderTrackShape(),
                   ),
                 ),
                child: Slider(
                  value: 0.7, // Mock progress
                  onChanged: (v) {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '02:48',
                      style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    Text(
                      '03:53',
                      style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLampControl() {
    return Column(
      children: [
        const SizedBox(height: 10),
        
        // Device Info & Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4),
                child: Image.asset(widget.deviceImage),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.deviceName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Phòng khách',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Switch
              CupertinoSwitch(
                value: _isDeviceOn,
                onChanged: (v) => setState(() => _isDeviceOn = v),
                activeColor: const Color(0xFF2962FF),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Tabs (White, Color, Scene)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildTabItem('Trắng', 0),
              _buildTabItem('Màu', 1),
              _buildTabItem('Cảnh', 2),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Circular Temperature Control (Only for White tab)
         if (_selectedTab == 0) ...[
           SizedBox(
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom Arc Painter
                GestureDetector(
                  onPanUpdate: (details) {
                    // Calculate angle from center to touch point
                    // This is a simplified interaction logic
                    RenderBox box = context.findRenderObject() as RenderBox;
                    Offset center = box.size.center(Offset.zero);
                    // Convert global touch to local
                    Offset local = box.globalToLocal(details.globalPosition);
                    // Need accurate local coordinates relative to the widget
                    // For simplicity in this demo, just using a mocked interaction or slider could be easier,
                    // but let's try to simulate the thumb moving.
                  },
                  child: CustomPaint(
                    size: const Size(280, 280),
                    painter: TemperatureArcPainter(
                      value: _temperature,
                      thumbRadius: 16,
                    ),
                  ),
                ),
                
                // Center Image
                Container(
                  width: 140,
                  height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(
                    widget.deviceImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
           ),
          ],

          // Circular Color Control (Only for Color tab)
          if (_selectedTab == 1) ...[
            SizedBox(
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Color Wheel Painter
                  CustomPaint(
                    size: const Size(300, 300),
                    painter: ColorWheelPainter(
                      hue: _hue,
                    ),
                  ),

                  // Center Image
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Image.asset(
                      widget.deviceImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],

         const Spacer(),
         
         // Brightness Slider
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 24),
           child: Row(
             children: [
               const Icon(Icons.wb_sunny_outlined, color: Colors.grey, size: 24),
               const SizedBox(width: 12),
               Expanded(
                 child: Theme(
                   data: ThemeData(
                     sliderTheme: SliderThemeData(
                       trackHeight: 12,
                       activeTrackColor: const Color(0xFF2962FF),
                       inactiveTrackColor: Colors.grey.shade200,
                       thumbColor: Colors.white, // In design it has a blue ring, standard thumb is close enough
                       thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14, elevation: 4),
                       overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                     ),
                   ),
                   child: Slider(
                     value: _brightness,
                     min: 0,
                     max: 100,
                     onChanged: (v) => setState(() => _brightness = v),
                   ),
                 ),
               ),
               const SizedBox(width: 12),
               Text(
                 '${_brightness.toInt()}%',
                 style: GoogleFonts.inter(
                   fontSize: 16,
                   color: Colors.black87,
                   fontWeight: FontWeight.w500,
                 ),
               ),
             ],
           ),
         ),
                      if (_selectedTab == 1) ...[
            const SizedBox(height: 16),
            // Intensity Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Half circle icon
                   Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 2),
                      gradient: const LinearGradient(
                        colors: [Colors.black87, Colors.transparent],
                        stops: [0.5, 0.5],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Theme(
                      data: ThemeData(
                        sliderTheme: SliderThemeData(
                          trackHeight: 12,
                          activeTrackColor: const Color(0xFF2962FF),
                          inactiveTrackColor: Colors.grey.shade200,
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 14, elevation: 4),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 24),
                        ),
                      ),
                      child: Slider(
                        value: _intensity,
                        min: 0,
                        max: 100,
                        onChanged: (v) => setState(() => _intensity = v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_intensity.toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
         const SizedBox(height: 32),
         
         // Bottom Button
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 24.0),
           child: SizedBox(
             width: double.infinity,
             height: 56,
             child: ElevatedButton(
               onPressed: () {},
               style: ElevatedButton.styleFrom(
                 backgroundColor: const Color(0xFFEBEFFF), // Light Blue
                 foregroundColor: const Color(0xFF2962FF),
                 elevation: 0,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(30),
                 ),
               ),
               child: Text(
                 'Lên lịch Bật/Tắt tự động',
                 style: GoogleFonts.inter(
                   fontSize: 15,
                   fontWeight: FontWeight.w600,
                 ),
               ),
             ),
           ),
         ),
         
         const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCCTVControl() {
    return Column(
      children: [
        const SizedBox(height: 10),
        
        // Device Info & Toggle (Reused layout but could be extracted)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4),
                child: Image.asset(widget.deviceImage),
              ),
              const SizedBox(width: 12),
              // Text and Switch same as Lamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.deviceName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Phòng khách',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: _isDeviceOn,
                onChanged: (v) => setState(() => _isDeviceOn = v),
                activeColor: const Color(0xFF2962FF),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // CCTV Video Feed
        Container(
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage('assets/images/kitchenroom.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Live Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Colors.red, size: 8),
                      const SizedBox(width: 4),
                      Text(
                        'Trực tiếp',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Overlay Controls
              Positioned(
                bottom: 12,
                right: 12,
                child: Row(
                  children: [
                    _buildOverlayButton(Icons.hd_outlined),
                    const SizedBox(width: 8),
                    _buildOverlayButton(Icons.volume_up_outlined),
                    const SizedBox(width: 8),
                    _buildOverlayButton(Icons.fullscreen),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        
        // Action Grid
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            children: [
              _buildFeatureItem(Icons.play_circle_outline, 'Xem lại'),
              _buildFeatureItem(Icons.camera_alt_outlined, 'Chụp ảnh'),
              _buildFeatureItem(Icons.mic_none_outlined, 'Đàm thoại'),
              _buildFeatureItem(Icons.videocam_outlined, 'Ghi hình'),
              _buildFeatureItem(Icons.image_outlined, 'Bộ sưu tập'),
              _buildFeatureItem(Icons.lock_outline, 'Riêng tư'), // Using Mode.. text might wrap
              _buildFeatureItem(Icons.nightlight_round_outlined, 'Ban đêm'),
              _buildFeatureItem(Icons.grid_view, 'Thêm'),
            ],
          ),
        ),
        
        // PTZ Controls
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               _buildCircleButton(Icons.arrow_back_ios_new, size: 48, color: Colors.grey.shade100, iconColor: Colors.black87),
               const SizedBox(width: 24),
               _buildCircleButton(Icons.pause, size: 64, color: const Color(0xFF2962FF), iconColor: Colors.white),
               const SizedBox(width: 24),
               _buildCircleButton(Icons.arrow_forward_ios, size: 48, color: Colors.grey.shade100, iconColor: Colors.black87),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
           child: Icon(icon, color: Colors.black87, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItemAC(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            // No shadow in design, or maybe very subtle.
          ),
           child: Icon(icon, color: Colors.grey.shade800, size: 26),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, {required double size, required Color color, required Color iconColor}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: size * 0.4),
    );
  }

  Widget _buildTabItem(String label, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2962FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildACTabItem(String label, int index) {
    bool isSelected = _acTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _acTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2962FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the Gradient Arc (Lamp)
class TemperatureArcPainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final double thumbRadius;

  TemperatureArcPainter({this.value = 0.5, this.thumbRadius = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // 1. Draw Gradient Arc
    const startAngle = 2.61799; // ~150 degrees
    const sweepAngle = 4.18879; // ~240 degrees
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      tileMode: TileMode.repeated,
      colors: const [
        Color(0xFFFFD54F), // Warm Yellow
        Color(0xFFFFE082),
        Colors.white,
        Color(0xFF90CAF9),
        Color(0xFF64B5F6), // Cool Blue
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 35
      ..strokeCap = StrokeCap.round;
    
    canvas.save();
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      paint,
    );
    canvas.restore();
    
    // 2. Draw Thumb
    final currentAngle = startAngle + (sweepAngle * value);
    final thumbX = center.dx + radius * math.cos(currentAngle);
    final thumbY = center.dy + radius * math.sin(currentAngle);
    final thumbCenter = Offset(thumbX, thumbY);
    
    canvas.drawCircle(thumbCenter, thumbRadius + 2, Paint()..color = Colors.white);
    canvas.drawCircle(thumbCenter, thumbRadius, Paint()..color = const Color(0xFFFFD54F).withOpacity(0.5));
    
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
      
    canvas.drawCircle(thumbCenter, thumbRadius, Paint()..color = Colors.white.withOpacity(0.3));
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Painter for Color Wheel (Lamp)
class ColorWheelPainter extends CustomPainter {
  final double hue; // 0-360

  ColorWheelPainter({this.hue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30; // Inner margin for wheel
    final tickRadius = size.width / 2 - 10;

    // 1. Draw Ticks
    final tickPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 360; i += 15) { // Every 15 degrees
      final angle = i * math.pi / 180;
      final start = Offset(
        center.dx + (tickRadius - 5) * math.cos(angle),
        center.dy + (tickRadius - 5) * math.sin(angle),
      );
      final end = Offset(
        center.dx + tickRadius * math.cos(angle),
        center.dy + tickRadius * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // 2. Draw Color Wheel
    const wheelThickness = 55.0;
    final wheelRect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      colors: const [
        Color(0xFFFF0000), // Red
        Color(0xFFFF00FF), // Magenta
        Color(0xFF0000FF), // Blue
        Color(0xFF00FFFF), // Cyan
        Color(0xFF00FF00), // Green
        Color(0xFFFFFF00), // Yellow
        Color(0xFFFF0000), // Red
      ],
      stops: const [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
    );

    final wheelPaint = Paint()
      ..shader = gradient.createShader(wheelRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wheelThickness
      ..strokeCap = StrokeCap.butt; 

    canvas.drawCircle(center, radius, wheelPaint);
    
    final screenshotGradient = SweepGradient(
      colors: const [
        Color(0xFF2962FF), // Blue (Right)
        Color(0xFF6200EA), // Purple
        Color(0xFFFF0000), // Red
        Color(0xFFFFFF00), // Yellow
        Color(0xFF00FF00), // Green
        Color(0xFF00FFFF), // Cyan
        Color(0xFF2962FF), // Blue
      ],
    );
     final screenshotPaint = Paint()
      ..shader = screenshotGradient.createShader(wheelRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wheelThickness;
      
      canvas.drawCircle(center, radius, screenshotPaint);

      // Thumb at 0 degrees (Right)
      final thumbAngle = 0.0;
      final thumbX = center.dx + radius * math.cos(thumbAngle);
      final thumbY = center.dy + radius * math.sin(thumbAngle);
      final thumbCenter = Offset(thumbX, thumbY);

      final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
      
      // Outer ring
      canvas.drawCircle(thumbCenter, 18, Paint()..color = Colors.white);
      // Inner fill (Blue)
      canvas.drawCircle(thumbCenter, 14, Paint()..color = const Color(0xFF2962FF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Painter for Volume Arc (Speaker)
class VolumeArcPainter extends CustomPainter {
  final double value; // 0.0 to 1.0

  VolumeArcPainter({this.value = 0.65});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;
    
    // Arc setup similar to Lamp but different visuals
    // Start from around 135 deg to 45 deg clockwise (open at bottom)
    const startAngle = 2.35619; // ~135 degrees
    const sweepAngle = 4.71239; // ~270 degrees sweep

    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // 1. Draw Ticks (Inner Ring)
    final tickPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
      
    final int totalTicks = 30;
    for (int i = 0; i <= totalTicks; i++) {
        final double tickProgress = i / totalTicks;
        final double angle = startAngle + (sweepAngle * tickProgress);
        
        // Ticks are now INSIDE the blue ring.
        // Main radius is `radius`. Blue ring has width 32.
        // So internal edge of blue ring is approx radius - 16.
        // Let's put ticks at radius - 40 to radius - 30.
        final double innerR = radius - 55;
        final double outerR = radius - 35;
        
        final p1 = Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle));
        final p2 = Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle));

        canvas.drawLine(p1, p2, tickPaint);
    }

    // 2. Draw Arc (Outer Ring)
    // Background Track (Grey)
    final trackPaint = Paint()
      ..color = const Color(0xFFF5F5F5) // Very light grey
      ..strokeWidth = 38
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    // Active Arc (Blue)
    final activePaint = Paint()
      ..color = const Color(0xFF2962FF)
      ..strokeWidth = 38 // Matches track width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, startAngle, sweepAngle * value, false, activePaint);
    
    // 3. Draw Thumb
    final currentAngle = startAngle + (sweepAngle * value);
    final thumbX = center.dx + radius * math.cos(currentAngle);
    final thumbY = center.dy + radius * math.sin(currentAngle);
    final thumbCenter = Offset(thumbX, thumbY);
    
    // White Circle with Blue Border
    final thumbFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    final thumbBorderPaint = Paint()
      ..color = const Color(0xFF2962FF)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
      
    // Shadow
    canvas.drawCircle(thumbCenter, 24, Paint()..color = Colors.black.withOpacity(0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    canvas.drawCircle(thumbCenter, 22, thumbFillPaint);
    canvas.drawCircle(thumbCenter, 22, thumbBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
