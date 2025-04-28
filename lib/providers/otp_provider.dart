// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:gem_biz_app/providers/auth_provider.dart';
// import 'package:gem_biz_app/providers/mobile_no_provider.dart';
// import 'package:gem_biz_app/providers/store_data_provider.dart';
// import 'package:gem_biz_app/screens/registration.dart';
// import 'package:gem_biz_app/screens/catalouge_screen.dart';
// import 'package:provider/provider.dart'; // Import your CatalogueScreen

// class OtpProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _isLoading = false;
//   String _errorMessage = '';
//   bool _otpVerified = false;
//   bool _isNavigating = false;

//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;
//   bool get otpVerified => _otpVerified;
//   bool get isNavigating => _isNavigating;

//   Future<void> reset() async {
//     _isLoading = false;
//     _errorMessage = '';
//     _otpVerified = false;
//     _isNavigating = false;
//     notifyListeners();
//   }

//   Future<void> sendOtp(String phoneNumber) async {
//     final mobileProvider = MobileNumberProvider();
//     await mobileProvider.sendOtp(phoneNumber);
//   }

//   Future<void> handlePostVerificationNavigation(BuildContext context, bool isUpdating) async {
//     if (_isNavigating) return;
    
//     try {
//       final User? user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         _errorMessage = 'Authentication failed';
//         notifyListeners();
//         return;
//       }

//       if (isUpdating) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Phone number updated successfully')),
//         );
//       } else {
//         // Let the main.dart handle the navigation based on auth state
//         await Provider.of<LoginStateProvider>(context, listen: false).checkLoginStatus();
//       }
//     } finally {
//       _isNavigating = false;
//       notifyListeners();
//     }
//   }

// Future<void> _signInWithCredential(PhoneAuthCredential credential, BuildContext? context, bool isUpdating) async {
//   try {
//     print("Starting _signInWithCredential");
//     UserCredential userCredential = await _auth.signInWithCredential(credential);
//     final uid = userCredential.user?.uid ?? '';
//     if (context != null) {
//       await Provider.of<LoginStateProvider>(context, listen: false).setLoggedIn(true);
//       await Future.delayed(const Duration(milliseconds: 500));

//     }
//     print("User signed in with UID: $uid");

//     _isLoading = false;
//     _otpVerified = true;
//     notifyListeners();
//     print("OTP verified and loading set to false");

//     if (context == null || !context.mounted) {
//       print("Context is null or not mounted, cannot navigate");
//       return;
//     }

//     if (isUpdating) {
//       print("Handling phone number update scenario");
//       await _firestore.collection('busers').doc(uid).set({
//         'phoneVerified': true,
//       }, SetOptions(merge: true));
//       print("User document updated with phoneVerified: true");

//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Phone number updated successfully')),
//       );
//     } else {
//       final isNewUser = await _isNewUser(uid);
//       print("Is new user: $isNewUser");

//       if (isNewUser) {
//         print("New user detected, creating user document");
//         await _firestore.collection('busers').doc(uid).set({
//           'uid': uid,
//           'phoneNumber': userCredential.user?.phoneNumber,
//           'createdAt': FieldValue.serverTimestamp(),
//           'phoneVerified': true,
//         });
//         print("New user document created in busers collection");
        
//         print("Navigating to RegistrationScreen");
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => RegistrationScreen()),
//         );
//       } else {
//         print("Existing user detected, checking for store");
//         bool storeExists = await _checkStoreExists(uid);
//         print("Store exists: $storeExists");

//         if (storeExists) {
//           await Provider.of<StoreDataProvider>(context, listen: false).fetchStoreData();
//           print("Store found, navigating to CatalogueScreen");
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => CatalogueScreen()),
//           );
//         } else {
//           print("No store found for existing user, navigating to RegistrationScreen");
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => RegistrationScreen()),
//           );
//         }
//       }
//     }
//   } catch (e) {
//     print("Error in _signInWithCredential: $e");
//     _isLoading = false;
//     _errorMessage = 'Failed to sign in. Please try again.';
//     notifyListeners();
//   }
// }

//   Future<bool> _isNewUser(String uid) async {
//     DocumentSnapshot userDoc = await _firestore.collection('busers').doc(uid).get();
//     return !userDoc.exists;
//   }

//   Future<bool> _checkStoreExists(String uid) async {
//     QuerySnapshot storeQuery = await _firestore
//         .collection('bregisterbusiness')
//         .where('uid', isEqualTo: uid)
//         .limit(1)
//         .get();
//     return storeQuery.docs.isNotEmpty;
//   }

//   Future<void> verifyOtp(String verificationId, String smsCode, BuildContext context, {bool isUpdating = false}) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: smsCode,
//       );
//       await _signInWithCredential(credential, context, isUpdating);
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = 'Verification failed. Please try again.';
//       notifyListeners();
//     }
//   }

//    Future<void> resendOtp(String phoneNumber) async {
//     try {
//       _isLoading = true;
//       _errorMessage = '';
//       notifyListeners();
      
//       await sendOtp(phoneNumber);
      
//       _isLoading = false;
//       notifyListeners();
      
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = 'Failed to resend OTP. Please try again.';
//       notifyListeners();
//     }
//   }

//   void setNavigating(bool navigating) {
//     _isNavigating = navigating;
//     notifyListeners();
//   }
// }
