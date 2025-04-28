// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:gem_biz_app/providers/auth_provider.dart';
//import 'package:gem_biz_app/providers/store_data_provider.dart';
import 'package:gem_biz_app/screens/create_account_screen.dart';
import 'package:gem_biz_app/screens/login_screen.dart';
import 'package:gem_biz_app/widgets/snackbar.dart';
//import 'package:gem_biz_app/screens/registration.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';


class BusinessDetailsScreen extends StatefulWidget {
  final String docId;

  const BusinessDetailsScreen({super.key, required this.docId});

  @override
  // ignore: library_private_types_in_public_api
  _BusinessDetailsScreenState createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  late Future<DocumentSnapshot> _businessDataFuture;
  late Stream<DocumentSnapshot> _verificationStream;

  @override
  void initState() {
    super.initState();
    _businessDataFuture = _fetchBusinessData();
     _verificationStream = FirebaseFirestore.instance
        .collection('bregisterbusiness')
        .doc(widget.docId)
        .snapshots();
  }

  Future<DocumentSnapshot> _fetchBusinessData() {
    return FirebaseFirestore.instance
        .collection('bregisterbusiness')
        .doc(widget.docId)
        .get();
  }

  void _refreshBusinessData() {
    setState(() {
      _businessDataFuture = _fetchBusinessData();
    });
  }

  Widget _buildVerificationStatus() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _verificationStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Checking verification status...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final isVerified = data?['storeverified'] ?? false;

        return Text(
          isVerified 
              ? 'Your Store is verified.'
              : 'Your Store Verification is still Under Pending.',
          style: TextStyle(
            fontSize: 12,
            color: isVerified ? Colors.green : Colors.orange,
            fontWeight: isVerified ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo and Business Name Shimmer
            Center(
              child: Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 300,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Business Details Card Shimmer
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerSection('Business Information'),
                    const Divider(color: Colors.grey, thickness: 0.5, height: 32),
                    _buildShimmerSection('Contact Information'),
                    const Divider(color: Colors.grey, thickness: 0.5, height: 32),
                    _buildShimmerSection('Additional Information'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Action Buttons Shimmer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Shimmer effect for details
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      height: 16,
                       decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      return;
    }

    // Add http:// prefix if not present
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = urlString;
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          showTopSnackBar(context, 'Could not launch the website');
        }
      }
    } catch (e) {
      if (mounted) {
        showTopSnackBar(context, 'Error launching website: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: _businessDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect();
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
          return const Center(child: Text('No business data found.'));
        }

          final data = snapshot.data!.data();
            if (data == null) {
              return const Center(child: Text('Business data is empty.'));
            }
          //Map<String, dynamic> businessData = snapshot.data!.data() as Map<String, dynamic>;
          Map<String, dynamic> businessData = data as Map<String, dynamic>;

          String logoUrl = businessData['logo_image_url'] ?? '';
          String storeTimings = businessData['store_timings'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Business Logo and Edit Button
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: logoUrl.isNotEmpty
                              ? NetworkImage(logoUrl)
                              : null,
                          child: logoUrl.isEmpty
                              ? const Icon(Icons.business, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          businessData['name'] ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildVerificationStatus(),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 300,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateBusinessAccountScreen(docId: widget.docId),
                                ),
                              ).then((_) {
                                _refreshBusinessData();
                              });
                            },
                            style: TextButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Edit'),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Business Details Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Business Information'),
                          const SizedBox(height: 16),
                          _buildDetailColumn('Business Name', businessData['name']),
                          _buildDetailColumn('Category', businessData['category']),
                          _buildDetailColumn('Description', businessData['description']),
                          _buildDetailColumn('GST Number', businessData['gst'] != null ? businessData['gst']['gst_no']?.toString() : null),
                          const Divider(color: Colors.grey, thickness: 0.5, height: 32),

                          _buildSectionTitle('Contact Information'),
                          const SizedBox(height: 16),
                          _buildDetailColumn('Mobile', businessData['mobile']),
                          _buildDetailColumn('Email', businessData['email']),
                          _buildDetailColumn('Website', businessData['website']),
                          _buildDetailColumn('Address', businessData['address']),
                          const Divider(color: Colors.grey, thickness: 0.5, height: 32),

                          _buildSectionTitle('Additional Information'),
                          const SizedBox(height: 16),
                          _buildDetailColumn('User Type', businessData['user_type']),
                          _buildDetailColumn('Store Timings', storeTimings),
                        ],
                      ),
                    ),
                  ),
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TextButton(
                        //   onPressed: () async {
                        //     bool confirmed = await _showConfirmationDialog(
                        //       context, 
                        //       'Delete Store', 
                        //       'Are you sure you want to delete your store? This will also delete all items in your store. This action is irreversible.'
                        //     );
                            
                        //     if (confirmed) {
                        //       try {
                        //         showDialog(
                        //           context: context,
                        //           barrierDismissible: false,
                        //           builder: (context) => const Center(
                        //             child: CircularProgressIndicator(),
                        //           ),
                        //         );
                    
                        //         final String currentUid = FirebaseAuth.instance.currentUser!.uid;
                        //         final storeDataProvider = Provider.of<StoreDataProvider>(context, listen: false);
                        //         await storeDataProvider.clearStoreData();
                        //         final QuerySnapshot itemsSnapshot = await FirebaseFirestore.instance
                        //             .collection('bbusinesscatalogue')
                        //             .where('uid', isEqualTo: currentUid)
                        //             .get();
                    
                        //         WriteBatch batch = FirebaseFirestore.instance.batch();
                        //         batch.delete(
                        //           FirebaseFirestore.instance
                        //               .collection('bregisterbusiness')
                        //               .doc(widget.docId)
                        //         );
                    
                        //         for (var doc in itemsSnapshot.docs) {
                        //           batch.delete(doc.reference);
                        //         }
                    
                        //         await batch.commit();
                    
                        //         final appAuthProvider = Provider.of<AppAuthProvider>(context, listen: false);
                        //         await appAuthProvider.setLastScreen('registration');
                    
                        //         Navigator.pop(context);
                        //         Navigator.of(context).pushAndRemoveUntil(
                        //           MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        //           (Route<dynamic> route) => false,
                        //         );
                        //       } catch (e) {
                        //         Navigator.pop(context);
                        //         showDialog(
                        //           context: context,
                        //           builder: (context) => AlertDialog(
                        //             title: const Text('Error'),
                        //             content: Text('Failed to delete store: ${e.toString()}'),
                        //             actions: [
                        //               TextButton(
                        //                 onPressed: () => Navigator.pop(context),
                        //                 child: const Text('OK'),
                        //               ),
                        //             ],
                        //           ),
                        //         );
                        //       }
                        //     }
                        //   },
                        //   style: TextButton.styleFrom(
                        //     foregroundColor: Colors.red,
                        //   ),
                        //   child: const Text('Delete Store'),
                        // ),
                        TextButton(
                          onPressed: () async {
                            bool confirmed = await _showConfirmationDialog(
                              context, 
                              'Log Out', 
                              'Are you sure you want to log out?'
                            );
                            
                            if (confirmed) {
                              try {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                    
                                await context.read<AppAuthProvider>().logout();
                                Navigator.pop(context);
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                                
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Error'),
                                      content: Text('Failed to log out: ${e.toString()}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

   Widget _buildDetailColumn(String title, String? value) {
    if (value == null || value.trim().isEmpty || value == 'N/A') {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          title.toLowerCase() == 'website'
              ? InkWell(
                  onTap: () => _launchUrl(value),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context, String title, String content) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }
}