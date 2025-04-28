// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MobileNumberProvider with ChangeNotifier {
//   bool _isLoading = false;
//   String? _verificationId;
//   String _errorMessage = '';
//   bool _otpSent = false;

//   bool get isLoading => _isLoading;
//   String? get verificationId => _verificationId;
//   String get errorMessage => _errorMessage;
//   bool get otpSent => _otpSent;

//   Future<void> reset() async {
//     _isLoading = false;
//     _errorMessage = '';
//     _otpSent = false;
//     _verificationId = null;
//     notifyListeners();
//   }

//   Future<void> sendOtp(String phoneNumber, {bool isUpdating = false}) async {
//     try {
//       await reset();
//       _isLoading = true;
//       notifyListeners();
      
//       await _verifyPhoneNumber(phoneNumber, isUpdating: isUpdating);
//     } catch (e) {
//       _errorMessage = 'Error: ${e.toString()}';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _verifyPhoneNumber(String phoneNumber, {bool isUpdating = false}) async {
//     final completer = Completer<void>();

//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: '+91$phoneNumber',
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         if (isUpdating) {
//           await _updatePhoneNumber(credential);
//         } else {
//           _verificationId = 'auto-verified';
//         }
//         _isLoading = false;
//         _otpSent = true;
//         notifyListeners();
//         completer.complete();
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         _errorMessage = e.message ?? 'Verification failed';
//         _isLoading = false;
//         notifyListeners();
//         completer.completeError(e);
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         _verificationId = verificationId;
//         _isLoading = false;
//         _otpSent = true;
//         notifyListeners();
//         completer.complete();
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         if (!_isLoading) {
//           _errorMessage = 'Verification code auto-retrieval timeout';
//           notifyListeners();
//         }
//       },
//     );

//     return completer.future;
//   }

//   Future<void> _updatePhoneNumber(PhoneAuthCredential credential) async {
//     try {
//       await FirebaseAuth.instance.currentUser?.updatePhoneNumber(credential);
//     } catch (e) {
//       _errorMessage = 'Failed to update phone number: ${e.toString()}';
//       notifyListeners();
//     }
//   }

//   Future<void> verifyOtp(String otp, {bool isUpdating = false}) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId!,
//         smsCode: otp,
//       );

//       if (isUpdating) {
//         await _updatePhoneNumber(credential);
//       } else {
//         await FirebaseAuth.instance.signInWithCredential(credential);
//       }

//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Invalid OTP: ${e.toString()}';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }