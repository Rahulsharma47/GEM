import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth for user UID
import 'package:flutter/material.dart';

class BusinessCategoryScreen extends StatefulWidget {
  const BusinessCategoryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BusinessCategoryScreenState createState() => _BusinessCategoryScreenState();
}

class _BusinessCategoryScreenState extends State<BusinessCategoryScreen> {
  final CollectionReference _categoriesRef = FirebaseFirestore.instance.collection('businesscategories');
  final User? _currentUser = FirebaseAuth.instance.currentUser; // Get current user

  // Function to add new category to Firestore
  Future<void> _addNewCategory(String category) async {
    if (_currentUser != null) {
      await _categoriesRef.add({
        'name': category,
        'createdBy': _currentUser.uid, // Store the current user's UID
        'status': 'pending',  // Set initial status to pending
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Business Category'),
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow for a cleaner look
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _categoriesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Fetching the list of categories from Firestore
          final List<DocumentSnapshot> categoriesDocs = snapshot.data?.docs ?? [];

          // Filter the categories based on status and user ID
          final List<String> visibleCategories = categoriesDocs
              .where((doc) {
                final data = doc.data() as Map<String, dynamic>;

                // Use null-aware operators to handle missing or null fields
                final String status = data['status'] as String? ?? 'pending';  // Default to 'pending' if null
                final String createdBy = data['createdBy'] as String? ?? '';   // Default to empty string if null

                // Show accepted categories to everyone, and pending categories only to the creator
                return (status == 'accepted') || (status == 'pending' && createdBy == _currentUser?.uid);
              })
              .map((doc) => doc['name'] as String? ?? 'Unnamed Category')  // Default to 'Unnamed Category' if name is null
              .toList();
            
          visibleCategories.sort((a, b) => a.compareTo(b));

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Add New Category button at the top
              GestureDetector(
                onTap: () => _showAddCategoryDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Add New Category',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0), // Space between button and list
              // List existing categories
               ...visibleCategories.asMap().entries.map((entry) {
                final isLast = entry.key == visibleCategories.length - 1;
                return Column(
                  children: [
                    ListTile(
                      title: Text(entry.value),
                      onTap: () {
                        Navigator.pop(context, entry.value);
                      },
                    ),
                    if (!isLast) const Divider(height: 1, thickness: 1),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // White background for dialog
          title: const Text('Add New Category', style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              hintText: 'Enter category name',
              hintStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black54), // Border color
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                if (categoryController.text.isNotEmpty) {
                  await _addNewCategory(categoryController.text);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
