import 'package:flutter/material.dart';
import 'package:iot_project/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
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
                          Text(
                            "Chào Mừng Trở Lại!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text("👋", style: TextStyle(fontSize: 28)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Ngôi Nhà Thông Minh, Theo Cách Của Bạn.",
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

                      // 4. Remember me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  activeColor: const Color(0xFF2972FF),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Ghi nhớ đăng nhập",
                                style: TextStyle(fontSize: 15, color: Colors.black),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: const Text(
                              "Quên mật khẩu?",
                              style: TextStyle(
                                color: Color(0xFF2972FF),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      // 5. Divider
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFF2F2F7), thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text("hoặc", style: TextStyle(color: Color(0xFF8E8E93))),
                          ),
                          Expanded(child: Divider(color: Color(0xFFF2F2F7), thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 6. Social Buttons
                       // 6. Social Buttons
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
                      const SizedBox(height: 16),
                      _buildSocialButton(
                        icon: Icons.facebook,
                        text: "Tiếp tục với Facebook",
                        onPressed: () {},
                        iconColor: const Color(0xFF1877F2),
                      ),

                      const SizedBox(height: 32), // Minimum gap from social buttons

                      // 7. Bottom Action
                       SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                           onPressed: () {
                            _handleLogin();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2972FF),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Đăng nhập",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Reduced bottom-most gap for better balance
                ],
              ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập Email và Mật khẩu")),
      );
      return;
    }

    _showLoadingDialog(context, "Đang đăng nhập...");

    try {
      await _apiService.login(email, password);
      
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Đóng loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng nhập thành công!"),
            backgroundColor: Color(0xFF2972FF),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Đóng loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()), 
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
            const SizedBox(width: 28), // Perfectly balance the icon on the left
          ],
        ),
      ),
    );
  }
}
