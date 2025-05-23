import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'main_screens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to Crafted-By-Her',
      'description':
          'Empowering women entrepreneurs to showcase their unique creations.',
      'image': 'assets/icon/icon.png',
    },
    {
      'title': 'Buy & Sell Easily',
      'description':
          'Connect with talented sellers or become one and share your products.',
      'image': 'assets/icon/icon.png',
    },
    {
      'title': 'Join the Community',
      'description':
          'Engage, learn, and grow with a supportive network of creators and buyers.',
      'image': 'assets/icon/icon.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressIndicator(),
                  Flexible(
                      child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: TextButton(
                      onPressed: _skip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color.fromARGB(255, 242, 92, 5),
                            fontSize: 16),
                      ),
                    ),
                  ))
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          onboardingData[index]['image']!,
                          width: 230,
                          height: 200,
                        ),
                        const SizedBox(height: 32),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            onboardingData[index]['title']!,
                            style: const TextStyle(
                              fontFamily: 'DMSerif',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 242, 92, 5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          onboardingData[index]['description']!,
                          style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 242, 92, 5),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(4), // Set corner radius here
                      ),
                      elevation: 0.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 245, 245, 245),
                          fontSize: 14,
                          letterSpacing: 0.2),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage >= index ? 20 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage >= index
                ? const Color.fromARGB(255, 242, 92, 5)
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
