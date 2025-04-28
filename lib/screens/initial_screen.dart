// import 'package:flutter/material.dart';
// import 'package:gem_biz_app/screens/registration.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gem_biz_app/providers/auth_provider.dart';
// import 'package:gem_biz_app/screens/onboarding_screen.dart';
// import 'package:gem_biz_app/screens/login_screen.dart';

// class InitialScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<SharedPreferences>(
//       future: SharedPreferences.getInstance(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           final prefs = snapshot.data!;
//           final onboardingCompleted = prefs.getBool('onboarding') ?? false;

//           return FutureBuilder<void>(
//             future: Provider.of<LoginStateProvider>(context, listen: false).checkLoginStatus(),
//             builder: (context, authSnapshot) {
//               if (authSnapshot.connectionState == ConnectionState.done) {
//                 final isLoggedIn = Provider.of<LoginStateProvider>(context, listen: false).isLoggedIn;

//                 if (!onboardingCompleted) {
//                   return OnboardingScreen();
//                 } else if (!isLoggedIn) {
//                   return LoginScreen();
//                 } else {
//                   return RegistrationScreen();
//                 }
//               }
//               return Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             },
//           );
//         }
//         return Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       },
//     );
//   }
// }