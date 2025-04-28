// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:gem_biz_app/providers/mobile_no_provider.dart';
// import 'package:gem_biz_app/auth/verification_otp_screen.dart';

// class UpdateNumberScreen extends StatefulWidget {
//   @override
//   _UpdateNumberScreenState createState() => _UpdateNumberScreenState();
// }

// class _UpdateNumberScreenState extends State<UpdateNumberScreen> {
//   final FocusNode _focusNode = FocusNode();
//   final TextEditingController _controller = TextEditingController();

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text('Update Mobile Number'),
//         backgroundColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Consumer<MobileNumberProvider>(
//             builder: (context, provider, child) {
//               if (provider.otpSent) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => VerificationOtpScreen(
//                         vid: provider.verificationId!,
//                         phoneNumber: _controller.text,
//                         isUpdating: true,
//                       ),
//                     ),
//                   );
//                 });
//               }
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   SizedBox(height: 40),
//                   Icon(
//                     Icons.phone_android,
//                     size: 80,
//                     color: Colors.black,
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'Update Mobile Number',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Enter your new mobile number',
//                     style: TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 40),
//                   GestureDetector(
//                     onTap: () {
//                       FocusScope.of(context).requestFocus(_focusNode);
//                     },
//                     child: TextField(
//                       focusNode: _focusNode,
//                       controller: _controller,
//                       keyboardType: TextInputType.phone,
//                       inputFormatters: [
//                         LengthLimitingTextInputFormatter(10),
//                         FilteringTextInputFormatter.digitsOnly,
//                       ],
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         labelText: 'New Mobile Number',
//                         hintText: 'Enter your new mobile number',
//                         prefixIcon: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Text(
//                             '+91',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: provider.isLoading
//                         ? null
//                         : () {
//                             if (_controller.text.length == 10) {
//                               provider.sendOtp(_controller.text, isUpdating: true);
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     'Please enter a valid 10-digit mobile number',
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       minimumSize: Size(double.infinity, 50),
//                     ),
//                     child: provider.isLoading
//                         ? CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                             'Update Number',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                   ),
//                   if (provider.errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10.0),
//                       child: Text(
//                         provider.errorMessage,
//                         style: TextStyle(color: Colors.red),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }