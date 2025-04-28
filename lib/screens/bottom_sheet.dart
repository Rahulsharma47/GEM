import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactOptionsBottomSheet extends StatelessWidget {
  final String phoneNumber = '+91 7799145959';
  final String whatsappNumber = '+917799145959';
  final String emailAddress = 'info@goextramile.in';

  const ContactOptionsBottomSheet({super.key});

  Future<String> _getMessageWithUserDetails() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return 'Error: User not logged in';

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bregisterbusiness')
          .where('uid', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 'Error: Business details not found';
      }

      final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      
      return '''Hi Go Extra Mile team, please verify my Business account.

Contact Details:
Business Name: ${data['name'] ?? 'N/A'}
Name: ${data['user_name'] ?? 'N/A'}
Contact Number: ${data['mobile'] ?? 'N/A'}
Email: ${data['email'] ?? 'N/A'}''';
    } catch (e) {
      return 'Error: Could not fetch business details';
    }
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    Navigator.pop(context); // Close the bottom sheet
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _openWhatsapp(BuildContext context) async {
    Navigator.pop(context); // Close the bottom sheet
    final message = await _getMessageWithUserDetails();
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$whatsappNumber?text=$encodedMessage');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    Navigator.pop(context); // Close the bottom sheet
    final body = await _getMessageWithUserDetails();
    final encodedSubject = Uri.encodeComponent('Account Verification Request');
    final encodedBody = Uri.encodeComponent(body);
    final Uri url = Uri.parse('mailto:$emailAddress?subject=$encodedSubject&body=$encodedBody');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenHeight < 600 ? 0.8 : 1.0;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20 * scaleFactor),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scaleFactor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 165.0 * scaleFactor),
              child: const Divider(
                color: Color.fromARGB(188, 0, 0, 0),
                height: 1,
              ),
            ),
            SizedBox(height: 10 * scaleFactor),
            Image.asset(
              'assets/images/verified.png',
              width: 150 * scaleFactor,
              height: 150 * scaleFactor,
            ),
            SizedBox(height: 10 * scaleFactor),
            Text(
              'Verify Account',
              style: TextStyle(
                fontSize: 20 * scaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10 * scaleFactor),
            Text(
              'Verify your account to sell your products directly to your customers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14 * scaleFactor),
            ),
            SizedBox(height: 30 * scaleFactor),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15 * scaleFactor),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _makePhoneCall(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15 * scaleFactor, horizontal: 20 * scaleFactor),
                      child: Row(
                        children: [
                          Icon(Icons.phone, color: Colors.white, size: 30 * scaleFactor),
                          SizedBox(width: 25 * scaleFactor),
                          Text(
                            'Call Us',
                            style: TextStyle(color: Colors.white, fontSize: 16 * scaleFactor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15 * scaleFactor),
                    child: Divider(color: Colors.grey[300], height: 1),
                  ),
                  InkWell(
                    onTap: () => _openWhatsapp(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5 * scaleFactor, horizontal: 5 * scaleFactor),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/watsapp.png',
                            width: 65 * scaleFactor,
                            height: 65 * scaleFactor,
                          ),
                          SizedBox(width: 5 * scaleFactor),
                          Text(
                            'WhatsApp Us',
                            style: TextStyle(color: Colors.white, fontSize: 16 * scaleFactor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15 * scaleFactor),
                    child: Divider(color: Colors.grey[300], height: 1),
                  ),
                  InkWell(
                    onTap: () => _sendEmail(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15 * scaleFactor, horizontal: 20 * scaleFactor),
                      child: Row(
                        children: [
                          Icon(Icons.email, color: Colors.white, size: 30 * scaleFactor),
                          SizedBox(width: 25 * scaleFactor),
                          Text(
                            'Email Us',
                            style: TextStyle(color: Colors.white, fontSize: 16 * scaleFactor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * scaleFactor),
          ],
        ),
      ),
    );
  }
}