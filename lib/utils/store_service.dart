// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getCurrentUID() {
    return _auth.currentUser?.uid;
  }

  Future<bool> doesStoreExist() async {
    String? uid = getCurrentUID();
    if (uid == null) return false;

    try {
      DocumentSnapshot storeDoc = await _firestore
          .collection('bregisterbusiness')
          .doc(uid)
          .get();

      return storeDoc.exists;
    } catch (e) {
      print('Error checking store existence: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchStoreForCurrentUser() async {
    String? uid = getCurrentUID();
    if (uid == null) return null;

    try {
      DocumentSnapshot storeDoc = await _firestore
          .collection('bregisterbusiness')
          .doc(uid)
          .get();

      if (storeDoc.exists) {
        return storeDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching store: $e');
      return null;
    }
  }

  Future<bool> createStore(Map<String, dynamic> storeData) async {
    String? uid = getCurrentUID();
    if (uid == null) return false;

    try {
      await _firestore
          .collection('bregisterbusiness')
          .doc(uid)
          .set(storeData);
      return true;
    } catch (e) {
      print('Error creating store: $e');
      return false;
    }
  }
}