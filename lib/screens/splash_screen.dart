import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gem_biz_app/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to Home after 3 seconds
    Timer(const Duration(seconds: 2), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',  // Add your image here
              width: 150,  // You can adjust width and height
              height: 150,
            ),
            const Text("Go Extra Mile", 
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20)),
            const Text("Business", 
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
