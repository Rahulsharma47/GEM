// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gem_biz_app/models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Save item using only itemId
  Future<void> saveItem(ItemModel item) async {
    try {
      await _firestore.collection('bbusinesscatalogue').doc(item.itemId).set(item.toMap());
      print('Item saved successfully: ${item.itemId}');
    } catch (e) {
      print('Error saving item: $e');
      throw Exception('Failed to save item: $e');
    }
  }

  // New method to update an item
  Future<void> updateItem(ItemModel item) async {
    try {
      await _firestore.collection('bbusinesscatalogue').doc(item.itemId).update(item.toMap());
      print('Item updated successfully: ${item.itemId}');
    } catch (e) {
      print('Error updating item: $e');
      throw Exception('Failed to update item: $e');
    }
  }

  // New method to delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection('bbusinesscatalogue').doc(itemId).delete();
      print('Item deleted successfully: $itemId');
    } catch (e) {
      print('Error deleting item: $e');
      throw Exception('Failed to delete item: $e');
    }
  }

  // Fetch item using only itemId
  Future<ItemModel?> getItem(String itemId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('bbusinesscatalogue').doc(itemId).get();
      if (doc.exists) {
        print('Item retrieved successfully: $itemId');
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print('Item not found: $itemId');
        return null;
      }
    } catch (e) {
      print('Error retrieving item: $e');
      throw Exception('Failed to retrieve item: $e');
    }
  }

  Stream<List<ItemModel>> streamItems() async* {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      yield [];
      return;
    }

    yield* _firestore
        .collection('bbusinesscatalogue')
        .where('uid', isEqualTo: currentUser.uid)  // Directly use Firebase Auth UID
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return ItemModel.fromMap(doc.data());
            } catch (e) {
              print('Error parsing document ${doc.id}: $e');
              return null;
            }
          }).whereType<ItemModel>().toList();
        });
  }
}