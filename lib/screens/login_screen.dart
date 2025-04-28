// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gem_biz_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:gem_biz_app/providers/auth_provider.dart';
import 'package:gem_biz_app/screens/registration.dart';
import 'package:gem_biz_app/screens/catalouge_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? tncUrl;
  Stream<DocumentSnapshot>? _urlStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _urlStream = FirebaseFirestore.instance
        .collection("badminvalues")
        .doc("admin")
        .snapshots();
        
    // Listen to the stream and update the URL
    _urlStream?.listen(
      (DocumentSnapshot snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            tncUrl = snapshot.get('tnc');
          });
        }
      },
      onError: (error) {
        print("Error streaming URL: $error");
      }
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url != null && await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

  Future _updateLastScreen(String screenName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastScreen', screenName);
      print("[LoginScreen] Updated lastScreen to: $screenName");
    } catch (e) {
      print("[LoginScreen] Error updating lastScreen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    //print("[LoginScreen] Building LoginScreen");
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        //print("[LoginScreen] Consumer rebuilding - Current status: ${authProvider.status}");
        
        // Handle navigation based on auth status using WidgetsBinding
        WidgetsBinding.instance.addPostFrameCallback((_) {
          //print("[LoginScreen] Post frame callback - Status: ${authProvider.status}");
          
          if (authProvider.status == AuthStatus.hasStore) {
            _updateLastScreen('catalogue');
            //print("[LoginScreen] Navigating to CatalogueScreen");
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CatalogueScreen()),
              (route) => false,
            );
          } else if (authProvider.status == AuthStatus.noStore) {
            _updateLastScreen('registration');
            //print("[LoginScreen] Navigating to RegistrationScreen");
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const RegistrationScreen()),
              (route) => false,
            );
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/logo.png',
                                        width: 150.0,
                                        height: 150.0,
                                      ),
                                      const Text(
                                        'Go Extra Mile',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Business',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  'Login or Signup',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                const SizedBox(height: 16.0),
                                _buildGoogleButton(context, authProvider.status == AuthStatus.authenticating),
                                const SizedBox(height: 16.0),
                                _buildPolicyText(),
                                const SizedBox(height: 30.0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Overlay loading indicator
                // if (authProvider.status == AuthStatus.authenticating)
                //   Container(
                //     color: Colors.black.withOpacity(0.3),
                //     child: const Center(
                //       child: CircularProgressIndicator(
                //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleButton(BuildContext context, bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading 
          ? null 
          : () async {
              try {
                await context.read<AppAuthProvider>().signInWithGoogle();
              } catch (e) {
                if (context.mounted) {
                  showTopSnackBar(context, 'Failed to sign in with Google');
                }
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        minimumSize: const Size(double.infinity, 50.0),
        disabledBackgroundColor: Colors.black,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 25.0,
            width: 25.0,
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  )
                : Image.asset(
                    'assets/images/google_icon.png',
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(width: 10),
          Text(
            isLoading ? 'Please wait...' : 'Continue with Google',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
}

  Widget _buildPolicyText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12.0,
          color: Colors.black,
        ),
        children: [
          const TextSpan(text: 'I agree to Go Extra Mile '),
          TextSpan(
            text: 'Terms & Conditions',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () {
              _launchUrl(tncUrl);
            },
          ),
          const TextSpan(text: ', '),
          TextSpan(
            text: 'Store Creation',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () {
              _launchUrl(tncUrl);
            },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Advertising Policies',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () {
              _launchUrl(tncUrl);
            },
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}