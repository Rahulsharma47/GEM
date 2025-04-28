// ignore_for_file: constant_identifier_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  hasStore,
  noStore,
}

class AppAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String IS_LOGGED_IN_KEY = 'is_logged_in';
  static const String HAS_STORE_KEY = 'has_store';
  static const String USER_UID_KEY = 'user_uid';

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? get currentUser => _auth.currentUser;

  AppAuthProvider() {
    //print("[AuthProvider] Initializing");
    _initializeAuthState();
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding", true);
  }

  Future<void> setLastScreen(String screenName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastScreen', screenName);
  }

  // Method to save status to SharedPreferences
  Future<void> _saveUserState({
    required bool isLoggedIn,
    required bool? hasStore,
    String? uid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(IS_LOGGED_IN_KEY, isLoggedIn);
    if (hasStore != null) {
      await prefs.setBool(HAS_STORE_KEY, hasStore);
    }
    if (uid != null) {
      await prefs.setString(USER_UID_KEY, uid);
    }
    print("[AuthProvider] Saved user state - LoggedIn: $isLoggedIn, HasStore: $hasStore, UID: $uid");
  }

    Future _initializeAuthState() async {
    print("[AuthProvider] Starting auth state initialization");
    
    // First check SharedPreferences
    final prefs = await SharedPreferences.getInstance();

      print("[AuthProvider] SharedPreferences initial values:");
      print("isLoggedIn: ${prefs.getBool(IS_LOGGED_IN_KEY)}");
      print("hasStore: ${prefs.getBool(HAS_STORE_KEY)}");
      print("userUid: ${prefs.getString(USER_UID_KEY)}");
      print("lastScreen: ${prefs.getString('lastScreen')}");
      print("onboarding: ${prefs.getBool('onboarding')}");

    final isLoggedIn = prefs.getBool(IS_LOGGED_IN_KEY) ?? false;
    final hasStore = prefs.getBool(HAS_STORE_KEY) ?? false;
    final savedUid = prefs.getString(USER_UID_KEY);

    if (isLoggedIn && savedUid != null) {
      _status = hasStore ? AuthStatus.hasStore : AuthStatus.noStore;
      notifyListeners();
    }

    // Then listen to Firebase auth changes
    _auth.authStateChanges().listen((User? user) async {
      print("[AuthProvider] Auth state changed - User: ${user?.uid}");
      
      if (user == null) {
        print("[AuthProvider] No user found, setting status to unauthenticated");
        _status = AuthStatus.unauthenticated;
        await _saveUserState(isLoggedIn: false, hasStore: null, uid: null);
      } else {
        final storeExists = await _checkStoreExistence(user.uid);
        final currentHasStore = prefs.getBool(HAS_STORE_KEY) ?? false;

        print("[AuthProvider] User found, checking store existence for UID: ${user.uid}");

       if (currentHasStore != storeExists) {
            _status = storeExists ? AuthStatus.hasStore : AuthStatus.noStore;
            await _saveUserState(
              isLoggedIn: true,
              hasStore: storeExists,
              uid: user.uid,
            );
          }
        print("[AuthProvider] Store check complete - HasStore: $storeExists, Status: $_status");
      }
      notifyListeners();
      print("[AuthProvider] Notified listeners of new status: $_status");
    });
  }

  Future<bool> _checkStoreExistence(String uid) async {
    try {
      print("[AuthProvider] Starting store existence check for UID: $uid");
      print("[AuthProvider] Accessing collection: 'bregisterbusiness'");
      
       final QuerySnapshot querySnapshot = await _firestore
          .collection('bregisterbusiness')
          .where('uid', isEqualTo: uid)
          .get();
      
      print("[AuthProvider] Found ${querySnapshot.docs.length} documents with matching UID");
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e, stackTrace) {
      print("[AuthProvider] Error checking store existence: $e");
      print("[AuthProvider] Stack trace: $stackTrace");
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      print("[AuthProvider] Starting Google Sign In process");
      _status = AuthStatus.authenticating;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("[AuthProvider] Google Sign In cancelled by user");
        _status = AuthStatus.unauthenticated;
        await _saveUserState(isLoggedIn: false, hasStore: null);
        notifyListeners();
        return;
      }

      print("[AuthProvider] Google Sign In successful for email: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        print("[AuthProvider] Firebase Auth successful for UID: ${user.uid}");
        await _saveUserToFirestore(user);

        final hasStore = await _checkStoreExistence(user.uid);
        print("[AuthProvider] Store check after sign in - HasStore: $hasStore");
        _status = hasStore ? AuthStatus.hasStore : AuthStatus.noStore;
        await _saveUserState(isLoggedIn: true, hasStore: hasStore, uid: user.uid,);
        print("[AuthProvider] Updated status to: $_status");
        notifyListeners();
      } 
    } catch (e) {
      print("[AuthProvider] Error during Google Sign In: $e");
      _status = AuthStatus.unauthenticated;
      await _saveUserState(isLoggedIn: false, hasStore: null);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      print("[AuthProvider] Saving user data to Firestore for UID: ${user.uid}");
      await _firestore.collection('busers').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("[AuthProvider] Successfully saved user data to Firestore");
    } catch (e) {
      print("[AuthProvider] Error saving user to Firestore: $e");
    }
  }

  Future<void> logout() async {
    try {
      print("[AuthProvider] Starting logout process");
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastScreen'); // Clear last screen on logout
      await prefs.remove(IS_LOGGED_IN_KEY);
      await prefs.remove(HAS_STORE_KEY);
      await prefs.remove(USER_UID_KEY);
      
      _status = AuthStatus.unauthenticated;
      print("[AuthProvider] Logout successful, status set to unauthenticated");
      notifyListeners();
    } catch (e) {
      print("[AuthProvider] Error during logout: $e");
      rethrow;
    }
  }
}