import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_biz_app/screens/create_account_screen.dart';  // Import flutter_svg package

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Go Extra Mile Business',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(), // Pushes the rest of the content to the center
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SvgPicture.asset(
                      'assets/images/business2.svg', // Ensure your SVG asset path is correct
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 24), // Space after the SVG
                    const Text(
                      'Business Registration',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16), // Space after the title
                    const Text(
                      'Complete your business registration to create your Catalogue, Scratch cards, and unlock more features.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32), // Space before the button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateBusinessAccountScreen()),
                          );// Add navigation or action for registration completion
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Set a smaller radius for less rounded corners
                          ),
                        ),
                        child: const Text('Register your Business'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(), // Adds space below the centered content
          ],
        ),
      ),
    );
  }
}
