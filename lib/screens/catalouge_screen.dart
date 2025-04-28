import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_biz_app/models/item_model.dart';
import 'package:gem_biz_app/screens/add_item_screen.dart';
import 'package:gem_biz_app/screens/item_details_screen.dart';
import 'package:gem_biz_app/screens/order_screen.dart';
import 'package:gem_biz_app/utils/firestore.dart';
import 'package:gem_biz_app/widgets/bottom_nav_bar.dart';
import 'package:gem_biz_app/widgets/custom_app_bar.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CatalogueScreenState createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  int _currentIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();

  void _navigateToAddItemScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemScreen(itemId: '',)),
    );
  }

  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderNowScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onNotificationTap: () {}),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<ItemModel>>(
        stream: _firestoreService.streamItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ItemModel> catalogueItems = snapshot.data ?? [];

          if (catalogueItems.isEmpty) {
            return _buildEmptyCatalogue();
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: catalogueItems.length,
              itemBuilder: (context, index) {
                final item = catalogueItems[index];
                return _buildGridItem(item);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildGridItem(ItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 65,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      image: item.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrls[0]),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.imageUrls.isEmpty
                        ? const Center(child: Icon(Icons.image, size: 40))
                        : null,
                  ),
                  if (item.hideItem)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(15)),
                        color: Colors.white.withOpacity(0.7),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.visibility_off,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                   if (item.itemStatus == 'pending' || item.itemStatus == 'rejected')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Image.asset(
                        item.itemStatus == 'pending'
                            ? 'assets/images/pending.png'
                            : 'assets/images/failed.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  if (item.hideItem)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Hidden',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 35,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: item.hideItem ? Colors.grey : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          '₹${item.mrp}',
                          style: TextStyle(
                            color: item.hideItem ? Colors.grey : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '₹${item.sellingPrice}',
                          style: TextStyle(
                            color: item.hideItem ? Colors.grey : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCatalogue() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'assets/images/cart2.svg',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text(
              'Create Catalogue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create your Catalogue and sell directly to your customers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToAddItemScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Create Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}