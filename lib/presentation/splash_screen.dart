import 'dart:async';
import 'package:crafted_by_her/presentation/super_admin_main.dart';
import 'package:flutter/material.dart';
import '../core/auth_view_model.dart';
import '../data/api_service.dart';
import '../data/prefference_keys.dart';
import 'onboarding_screen.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(PreferencesKeys.isLoggedInKey) ?? false;
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/icon.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            const Text(
              'Crafted-By-Her',
              style: TextStyle(
                fontFamily: 'DMSerif',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 242, 92, 5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
