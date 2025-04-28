import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:gem_biz_app/providers/store_verification_provider.dart';
import 'package:gem_biz_app/widgets/custom_app_bar.dart';
import 'package:gem_biz_app/screens/catalouge_screen.dart';
import 'package:gem_biz_app/widgets/bottom_nav_bar.dart';
//import 'package:provider/provider.dart';

class OrderNowScreen extends StatefulWidget {
  const OrderNowScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrderNowScreenState createState() => _OrderNowScreenState();
}

class _OrderNowScreenState extends State<OrderNowScreen> {
  int _currentIndex = 2; // Set to 2 for the Orders tab

  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      // Handle navigation to other screens here
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CatalogueScreen()),
        );
      }
      // Note: index 1 (Add Item) is handled in the BottomNavBar widget
    }
  }

  void _handleNotificationTap() {
    // Handle navigation to the notification page
  }

  @override
  Widget build(BuildContext context) {
    List<String> orders = []; // Replace with actual data fetching logic

    return Scaffold(
      appBar: CustomAppBar(onNotificationTap: _handleNotificationTap),
      backgroundColor: Colors.white,
      body: orders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/cart2.svg',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Orders',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You do not have any orders yet. All your orders will be shown here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(orders[index]),
                );
              },
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}