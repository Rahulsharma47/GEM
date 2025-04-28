import 'package:flutter/material.dart';
import 'package:gem_biz_app/screens/bottom_sheet.dart';
import 'package:gem_biz_app/screens/notification_screen.dart';
import 'package:provider/provider.dart';
import 'package:gem_biz_app/providers/store_data_provider.dart';
import 'package:gem_biz_app/providers/store_verification_provider.dart';
import 'package:gem_biz_app/screens/business_details_screen.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onNotificationTap;

  const CustomAppBar({super.key, required this.onNotificationTap});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final verificationProvider = Provider.of<StoreVerificationProvider>(context, listen: false);
      verificationProvider.initializeVerificationStatus();
    });
  }

  String truncateWithEllipsis(String text, int maxLength) {
    return text.length <= maxLength 
        ? text 
        : '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreDataProvider>(context);
    final business = storeProvider.business;
    final docId = storeProvider.docId;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (docId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusinessDetailsScreen(docId: docId)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Business ID is not available')),
                );
              }
            },
            child: CircleAvatar(
              backgroundImage: business?['logo_image_url'] != null && business!['logo_image_url'].isNotEmpty
                  ? NetworkImage(business['logo_image_url'])
                  : const AssetImage('assets/images/store_logo.png') as ImageProvider,
              radius: 20,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              truncateWithEllipsis(business?['name'] ?? 'My Store', 20),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Consumer<StoreVerificationProvider>(
              builder: (context, verificationProvider, child) {
              final isVerified = verificationProvider.isVerified;
                return GestureDetector(
                  onTap: () {
                    if (!isVerified && docId != null) {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => const ContactOptionsBottomSheet(),
                      );
                    }
                  },
                  child: Switch(
                    value: isVerified,
                    onChanged: null,
                    activeColor: Colors.green,
                    inactiveTrackColor: Colors.transparent,
                    inactiveThumbColor: Colors.black,
                    activeTrackColor: Colors.grey,
                  ),
                );
              },
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}