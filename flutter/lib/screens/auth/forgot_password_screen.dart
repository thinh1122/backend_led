import 'package:flutter/material.dart';

import 'package:iot_project/widgets/custom_button.dart';
import 'package:iot_project/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Quên Mật Khẩu? 🔑",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                "Đừng lo lắng. Nhập email đã đăng ký của bạn để đặt lại mật khẩu. Chúng tôi sẽ gửi mã OTP đến email của bạn để thực hiện các bước tiếp theo.",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Your Registered Email",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hintText: "andrew.ainsley@yourdomain.com",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                fillColor: Colors.grey[50],
                textColor: Colors.black,
              ),
              const Spacer(),
              CustomButton(
                text: "Gửi Mã OTP",
                onPressed: () {
                  // TODO: Implement forgot password logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chức năng OTP chưa được triển khai")),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
