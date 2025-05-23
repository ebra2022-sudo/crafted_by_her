import 'package:crafted_by_her/domain/models/user.dart';
import 'package:crafted_by_her/presentation/admin_main.dart';
import 'package:crafted_by_her/presentation/main_screens.dart';
import 'package:crafted_by_her/presentation/super_admin_main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/auth_view_model.dart';
import '../data/api_service.dart';
import '../data/prefference_keys.dart';
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
    final String? storedRole = prefs.getString(PreferencesKeys.userKey); // Correct key for role
    if (!mounted) return;

    if (isLoggedIn) {
      final auth = context.read<AuthViewModel>().user;
      if (auth?.role != null) {
        switch (auth!.role) {
          case Role.user:
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserMainScreen()),
              );
            }
            break;
          case Role.admin:
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminMainScreen()),
              );
            }
            break;
          case Role.superAdmin:
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SuperAdminMainScreen()),
              );
            }
            break;
          default:
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingScreen()),
              );
            }
            break;
        }
      } else if (storedRole != null) {
        // Fallback to stored role if auth.role is null
        final role = Role.values.firstWhere(
              (r) => r.toString().split('.').last == storedRole,
          orElse: () => Role.user,
        );
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => role == Role.user
                  ? const UserMainScreen()
                  : role == Role.admin
                  ? const AdminMainScreen()
                  : const SuperAdminMainScreen(),
            ),
          );
        }
      } else {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
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