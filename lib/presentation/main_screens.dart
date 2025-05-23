import 'dart:ui';

import 'package:crafted_by_her/presentation/category_screen.dart';
import 'package:crafted_by_her/presentation/home_screen.dart';
import 'package:crafted_by_her/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/auth_view_model.dart';
import '../data/prefference_keys.dart';
import 'profile_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});
  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadAllProducts();
  }

  void loadAllProducts() async {
    // Your custom logic here
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.fetchProductsByCategory('All');

    // You can perform other tasks here too, like fetching user data, checking updates, etc.
  }

  // Screens to switch between
  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const SellerProfileScreen()
  ];

  void _onItemTapped(int index) async {
    // Account tab is at index 2
    if (index == 2) {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(PreferencesKeys.isLoggedInKey) ?? false;
      print("Loggin status ${isLoggedIn}");

      if (!isLoggedIn) {
        // Navigate to login screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return; // Don't change tab index
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 242, 92, 5),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/home.svg',
              colorFilter: _selectedIndex == 0
                  ? const ColorFilter.mode(
                      Color.fromARGB(255, 242, 92, 5), BlendMode.srcIn)
                  : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/category.svg',
              color: _selectedIndex == 1
                  ? const Color.fromARGB(255, 242, 92, 5)
                  : Colors.grey,
            ),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/account.svg',
              color: _selectedIndex == 2
                  ? const Color.fromARGB(255, 242, 92, 5)
                  : Colors.grey,
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
