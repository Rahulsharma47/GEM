import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_biz_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/card.svg',
      'text': 'Scratch Cards',
      'subtext': 'Create scratch cards for your business'
    },
    {
      'image': 'assets/images/business.svg',
      'text': 'Increase your Business',
      'subtext': 'Increase customer recall after a ride',
    },
    {
      'image': 'assets/images/cart.svg',
      'text': 'Sell Products',
      'subtext': 'Sell products directly to your customers',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLastPage() {
    _pageController.animateToPage(
      onboardingData.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding", true);

    if (!mounted) return;
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
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        onboardingData[index]['image']!,
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        onboardingData[index]['text']!,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        onboardingData[index]['subtext']!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            // Navigation row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button (hidden on last page)
                  _currentIndex < onboardingData.length - 1
                      ? TextButton(
                          onPressed: _goToLastPage,
                          child: const Text(
                            'Skip',
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      : const SizedBox(width: 64), // Placeholder to maintain layout
                  // Dots Indicator
                  Row(
                    children: onboardingData.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == entry.key
                              ? Colors.black
                              : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                  // Next button or Login/Signup button
                  _currentIndex < onboardingData.length - 1
                      ? IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.black),
                          onPressed: _goToNextPage,
                        )
                      : TextButton(
                          onPressed: _completeOnboarding,
                          child: const Text(
                            'Login/Signup',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
