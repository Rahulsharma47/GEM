// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:gem_biz_app/auth/verification_otp_screen.dart';
// import 'package:gem_biz_app/providers/mobile_no_provider.dart'; // Assuming this replaces MobileNumberBloc

// class MobileNumberScreen extends StatefulWidget {
//   @override
//   _MobileNumberScreenState createState() => _MobileNumberScreenState();
// }

// class _MobileNumberScreenState extends State<MobileNumberScreen> {
//   final FocusNode _focusNode = FocusNode();
//   final TextEditingController _controller = TextEditingController();
//   bool _hasNavigated = false;  // Add this flag


//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//    @override
//   void initState() {
//     super.initState();
//     // Reset the provider state when screen initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<MobileNumberProvider>(context, listen: false).reset();
//     });
//   }
  
//   // @override
//   // Widget build(BuildContext context) {
//   //   return ChangeNotifierProvider(
//   //     create: (_) => MobileNumberProvider(),
//   //     child: Scaffold(
//   //       backgroundColor: Colors.white,
//   //       body: SafeArea(
//   //         child: Padding(
//   //           padding: EdgeInsets.all(16.0),
//   //           child: Consumer<MobileNumberProvider>(
//   //             builder: (context, provider, child) {
//   //               if (provider.otpSent) {
//   //                 // Redirect to OTP verification screen
//   //                 WidgetsBinding.instance.addPostFrameCallback((_) {
//   //                   Navigator.push(
//   //                     context,
//   //                     MaterialPageRoute(
//   //                       builder: (context) => VerificationOtpScreen(
//   //                         vid: provider.verificationId!,
//   //                         phoneNumber: _controller.text,
//   //                         isUpdating: false,
//   //                       ),
//   //                     ),
//   //                   );
//   //                 });
//   //               }

//        @override
//         Widget build(BuildContext context) {
//           // Use existing provider instead of creating new one
//           return Scaffold(
//             backgroundColor: Colors.white,
//             body: SafeArea(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Consumer<MobileNumberProvider>(
//                   builder: (context, provider, child) {
//                     // Handle navigation with proper check
//                     if (provider.otpSent && !_hasNavigated) {
//                       _hasNavigated = true;
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         if (mounted) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => VerificationOtpScreen(
//                                 vid: provider.verificationId!,
//                                 phoneNumber: _controller.text,
//                                 isUpdating: false,
//                               ),
//                             ),
//                           );
//                         }
//                       });
//                     }
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Align(
//                       alignment: Alignment.topLeft,
//                       child: IconButton(
//                         icon: Icon(Icons.close, size: 30),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ),
//                     SizedBox(height: 100),
//                     Icon(
//                       Icons.call,
//                       size: 80,
//                       color: Colors.black,
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Verify Mobile No.',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'OTP will be sent to your mobile no.',
//                       style: TextStyle(fontSize: 16),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 40),
//                     GestureDetector(
//                       onTap: () {
//                         FocusScope.of(context).requestFocus(_focusNode);
//                       },
//                       child: TextField(
//                         focusNode: _focusNode,
//                         controller: _controller,
//                         keyboardType: TextInputType.phone,
//                         inputFormatters: [
//                           LengthLimitingTextInputFormatter(10),
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: 'Mobile Number',
//                           hintText: 'Enter your mobile number',
//                           prefixIcon: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Text(
//                               '+91',
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: provider.isLoading
//                           ? null
//                           : () {
//                               if (_controller.text.length == 10) {
//                                 provider.sendOtp(_controller.text, isUpdating: false);
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       'Please enter a valid 10-digit mobile number',
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         padding: EdgeInsets.symmetric(vertical: 16),
//                         minimumSize: Size(double.infinity, 50),
//                       ),
//                       child: provider.isLoading
//                           ? CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                               'Get OTP',
//                               style: TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                     ),
//                     if (provider.errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 10.0),
//                         child: Text(
//                           provider.errorMessage,
//                           style: TextStyle(color: Colors.red),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     Spacer(),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       );
//   }
// }