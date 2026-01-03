import 'package:flutter/material.dart';
import 'package:iot_project/theme.dart';
import 'package:iot_project/screens/onboarding/onboarding_screen.dart';
import 'package:iot_project/screens/auth/welcome_screen.dart';
import 'package:iot_project/screens/auth/login_screen.dart';
import 'package:iot_project/screens/auth/signup_screen.dart';
import 'package:iot_project/screens/auth/forgot_password_screen.dart';
import 'package:iot_project/screens/dashboard/home_screen.dart';
import 'package:iot_project/screens/onboarding/splash_screen.dart';
import 'package:iot_project/screens/auth/select_country_screen.dart';
import 'package:iot_project/screens/auth/add_home_name_screen.dart';
import 'package:iot_project/screens/auth/add_rooms_screen.dart';
import 'package:iot_project/screens/auth/set_location_screen.dart';
import 'package:iot_project/screens/auth/setup_complete_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smartify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Layout designed for Light Theme
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/select_country': (context) => const SelectCountryScreen(),
        '/add_home_name': (context) => const AddHomeNameScreen(),
        '/add_rooms': (context) => const AddRoomsScreen(),
        '/set_location': (context) => const SetLocationScreen(),
        '/setup_complete': (context) => const SetupCompleteScreen(),
      },
    );
  }
}
