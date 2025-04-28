import 'package:flutter/material.dart';
import 'package:gem_biz_app/screens/add_item_screen.dart';
import 'package:gem_biz_app/screens/order_screen.dart';
import 'package:provider/provider.dart';
import 'package:gem_biz_app/providers/store_verification_provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreVerificationProvider>(
      builder: (context, storeProvider, child) {
        final itemId = storeProvider.presentItem?.id ?? '';

        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == 1) {
              // Navigate to Add Item screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemScreen(itemId: itemId)),
              );
            } else if (index == 2) {
              // Navigate to Order screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OrderNowScreen()),
              );
            } else {
              // Handle navigation for other tabs
              onTap(index);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront),
              label: 'Catalogue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Add Item',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
          ],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          elevation: 0,
        );
      },
    );
  }
}