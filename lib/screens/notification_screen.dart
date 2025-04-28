import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  void _handleNotificationTap() {
    // Placeholder for notification tap functionality
  }

  @override
  Widget build(BuildContext context) {
    List<String> notifications = []; // Placeholder for notifications data

    return Scaffold(
      backgroundColor: Colors.white,
      body: notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/notifications.svg', // Update the image to match the notification screen
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You do not have any notifications yet. All your notifications will be shown here.',
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
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notifications[index]),
                );
              },
            ),
    );
  }
}
