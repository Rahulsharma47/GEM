// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:gem_biz_app/providers/otp_provider.dart';
// import 'package:pinput/pinput.dart';


// class VerificationOtpScreen extends StatefulWidget {
//   final String vid;
//   final String phoneNumber;
//   final bool isUpdating;

//   const VerificationOtpScreen({
//     Key? key,
//     required this.vid,
//     required this.phoneNumber,
//     required this.isUpdating,
//   }) : super(key: key);

//   @override
//   _VerificationOtpScreenState createState() => _VerificationOtpScreenState();
// }

// class _VerificationOtpScreenState extends State<VerificationOtpScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   bool _hasNavigated = false;


//   @override
//   void dispose() {
//     _otpController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Reset navigation state when screen initializes
//     _hasNavigated = false;
//     Provider.of<OtpProvider>(context, listen: false).reset();
//   }

//  @override
//   Widget build(BuildContext context) {
//     // Use existing provider instead of creating new one
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Consumer<OtpProvider>(
//             builder: (context, provider, child) {
//               // Improved navigation logic
//               if (provider.otpVerified && !provider.isNavigating && !_hasNavigated) {
//                 _hasNavigated = true;
//                 provider.setNavigating(true);
//                 // Let the provider handle navigation
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   if (mounted) {
//                     provider.handlePostVerificationNavigation(context, widget.isUpdating);
//                   }
//                 });
//               }
//                 return SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       SizedBox(height: 100),
//                       Icon(
//                         Icons.message,
//                         size: 80,
//                         color: Colors.black,
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         widget.isUpdating ? 'Update Number' : 'Verify OTP',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 10),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'OTP has been sent to your mobile number.',
//                             style: TextStyle(fontSize: 12),
//                             textAlign: TextAlign.center,
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: Text(
//                               'Wrong number?',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 40),
//                       Pinput(
//                         controller: _otpController,
//                         length: 6,
//                         keyboardType: TextInputType.number,
//                         defaultPinTheme: PinTheme(
//                           width: 56,
//                           height: 56,
//                           textStyle: TextStyle(
//                             fontSize: 20,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.black),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         focusedPinTheme: PinTheme(
//                           width: 56,
//                           height: 56,
//                           textStyle: TextStyle(
//                             fontSize: 20,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.blue),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         submittedPinTheme: PinTheme(
//                           width: 56,
//                           height: 56,
//                           textStyle: TextStyle(
//                             fontSize: 20,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.green),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: provider.isLoading
//                             ? null
//                             : () {
//                                 if (_otpController.text.length == 6) {
//                                   provider.verifyOtp(widget.vid, _otpController.text, context, isUpdating: widget.isUpdating);
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text('Please enter a 6-digit OTP')),
//                                   );
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           padding: EdgeInsets.symmetric(vertical: 16),
//                           minimumSize: Size(double.infinity, 50),
//                         ),
//                         child: provider.isLoading
//                             ? CircularProgressIndicator(color: Colors.white)
//                             : Text(
//                                 widget.isUpdating ? 'Update' : 'Verify',
//                                 style: TextStyle(color: Colors.white, fontSize: 16),
//                               ),
//                       ),
//                       SizedBox(height: 20),
//                       TextButton(
//                         onPressed: provider.isLoading
//                             ? null
//                             : () {
//                                 provider.resendOtp(widget.phoneNumber);
//                               },
//                         child: Text(
//                           'Resend OTP',
//                           style: TextStyle(color: Colors.black),
//                         ),
//                       ),
//                       if (provider.errorMessage.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 10.0),
//                           child: Text(
//                             provider.errorMessage,
//                             style: TextStyle(color: Colors.red),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       );
//   }
// }