import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/dashboard.dart';
import 'package:lgbt_togo/Features/Screens/auth/helper.dart';
import 'package:lgbt_togo/Features/Screens/auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    checkLoginStatus(context);
    super.initState();
  }

  // check is this user login or logout
  Future<void> checkLoginStatus(BuildContext context) async {
    final isLoggedIn = await AuthHelper.isUserLoggedIn();
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
