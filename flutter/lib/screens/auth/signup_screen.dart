import 'package:flutter/material.dart';
import 'package:iot_project/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      // 1. Header Section
                      const Row(
                        children: [
                           Expanded(
                             child: Text(
                              "Tham Gia Smartify Ngay",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                           ),
                          SizedBox(width: 8),
                          Icon(Icons.person, color: Color(0xFF637381), size: 32),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Tham gia Smartify, Cánh cửa đến với cuộc sống thông minh.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 2. Email Field
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                       _buildTextField(
                        hint: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 24),

                       const SizedBox(height: 24),

                      // 3. Password Field
                      const Text(
                        "Mật khẩu",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                       _buildTextField(
                        hint: "Mật khẩu",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF8E8E93),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Agreement Checkbox - Left Aligned for balance
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Theme(
                            data: ThemeData(unselectedWidgetColor: const Color(0xFFE5E5EA)),
                            child: Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: const BorderSide(color: Color(0xFF8E8E93), width: 2.0), // Darker and thicker border
                              activeColor: const Color(0xFF2972FF),
                            ),
                          ),
                          const Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: "Tôi đồng ý với ",
                                children: [
                                  TextSpan(
                                    text: "Điều khoản & Điều kiện.",
                                    style: TextStyle(
                                      color: Color(0xFF2972FF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 5. Existing Account Navigation - Centered
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Đã có tài khoản? ",
                              style: TextStyle(color: Colors.black, fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: const Text(
                                "Đăng nhập",
                                style: TextStyle(
                                  color: Color(0xFF2972FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 6. Divider
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFF2F2F7), thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text("or", style: TextStyle(color: Color(0xFF8E8E93))),
                          ),
                          Expanded(child: Divider(color: Color(0xFFF2F2F7), thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 7. Social Buttons - Enhanced Balance
                       // 7. Social Buttons - Enhanced Balance
                      _buildSocialButton(
                        iconWidget: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                          width: 24,
                          height: 24,
                        ),
                        text: "Tiếp tục với Google",
                        onPressed: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildSocialButton(
                        icon: Icons.apple,
                        text: "Tiếp tục với Apple",
                        onPressed: () {},
                        iconColor: Colors.black,
                      ),

                      const SizedBox(height: 32), 

                      // 8. Bottom Action
                       SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                           onPressed: () {
                            _handleSignup();
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
                      const SizedBox(height: 12), // Tighter bottom gap for a cleaner finish
                ],
              ),
        ),
      ),
    );
  }

  void _handleSignup() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn cần đồng ý với điều khoản dịch vụ")),
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu phải có ít nhất 6 ký tự")),
      );
      return;
    }

    _showLoadingDialog(context, "Đang đăng ký...");

    try {
      await _apiService.signup(email, password);
      
      if (mounted) {
        // Safe way to close loading dialog
        Navigator.of(context, rootNavigator: true).pop(); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký thành công! Đang thiết lập nhà mới..."),
            backgroundColor: Color(0xFF2972FF),
          ),
        );
        
        // Chuyển sang luồng thiết lập nhà mới sau 1 giây
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/select_country');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Đảm bảo đóng loading dialog nếu có lỗi
        Navigator.of(context, rootNavigator: true).pop(); 
        
        String errorMsg = e.toString();
        // Xử lý các lỗi phổ biến từ Backend
        if (errorMsg.contains("Mật khẩu phải có ít nhất 6 ký tự")) {
          errorMsg = "Mật khẩu quá ngắn (tối thiểu 6 ký tự)!";
        } else if (errorMsg.contains("Email đã tồn tại") || errorMsg.contains("User already exists")) {
          errorMsg = "Email này đã được đăng ký. Vui lòng đăng nhập!";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

   void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2972FF)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC7C7CC), fontSize: 16),
        prefixIcon: Icon(icon, color: const Color(0xFF8E8E93)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2972FF), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    Widget? iconWidget,
    required String text,
    Color? iconColor,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF2F2F7)),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          children: [
            if (iconWidget != null) iconWidget,
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
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}
