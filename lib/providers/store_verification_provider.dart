// ignore_for_file: avoid_print

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gem_biz_app/models/item_model.dart';

class StoreVerificationProvider with ChangeNotifier {
  bool? _isVerified;
  ItemModel? _savedItem;
  ItemModel? _presentItem;
  StreamSubscription<DocumentSnapshot>? _verificationSubscription;

  bool get isVerified => _isVerified ?? false;
  ItemModel? get savedItem => _savedItem;
  ItemModel? get presentItem => _presentItem;

  void setCurrentItem(ItemModel item) {
    _presentItem = item;
    notifyListeners();
  }

  void saveItem(ItemModel item) {
    _savedItem = item;
    notifyListeners();
  }

  void initializeVerificationStatus() {
    // Get current user UID
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    
    if (currentUserUid == null) {
      //print('No user logged in');
      return;
    }

    //print('Initializing verification status for UID: $currentUserUid');

    // Cancel any existing subscription
    _verificationSubscription?.cancel();

    // Create new subscription that listens to the document where uid matches
    _verificationSubscription = FirebaseFirestore.instance
        .collection('bregisterbusiness')
        .where('uid', isEqualTo: currentUserUid)
        .snapshots()
        .listen(
      (QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final data = doc.data() as Map<String, dynamic>;
          //print('Received document data: $data');
          
          final newValue = data['storeverified'] ?? false;
          if (_isVerified != newValue) {
            _isVerified = newValue;
            //print('Verification status updated to: $_isVerified');
            notifyListeners();
          }
        } else {
          print('No document found for current user');
          _isVerified = false;
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error in verification stream: $error');
      },
    ) as StreamSubscription<DocumentSnapshot<Object?>>?;
  }

  Future<void> toggleVerification() async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    
    if (currentUserUid == null) {
      //print('No user logged in');
      return;
    }

    try {
      // First, get the document reference
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bregisterbusiness')
          .where('uid', isEqualTo: currentUserUid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        
        // Only allow changing from false to true
        if (_isVerified == false) {
          await docRef.update({'storeverified': true});
          //print('Updated verification status to true');
        }
      } else {
        //print('No document found for current user');
      }
    } catch (e) {
      //print('Error updating verification status: $e');
    }
  }

  @override
  void dispose() {
    _verificationSubscription?.cancel();
    super.dispose();
  }
}
