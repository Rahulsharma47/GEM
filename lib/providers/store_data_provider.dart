// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimeSlot {
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  TimeSlot({this.openTime, this.closeTime});

  Map<String, dynamic> toMap() {
    return {
      'openTime': openTime != null ? '${openTime!.hour}:${openTime!.minute}' : null,
      'closeTime': closeTime != null ? '${closeTime!.hour}:${closeTime!.minute}' : null,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    String? openTimeStr = map['openTime'];
    String? closeTimeStr = map['closeTime'];
    
    return TimeSlot(
      openTime: openTimeStr != null ? _parseTimeOfDay(openTimeStr) : null,
      closeTime: closeTimeStr != null ? _parseTimeOfDay(closeTimeStr) : null,
    );
  }

  static TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]), 
        minute: int.parse(parts[1])
      );
    } catch (e) {
      print('Error parsing time: $e');
      return null;
    }
  }
}

class StoreData {
  Map<String, List<TimeSlot>> storeTimes;
  String availability;
  List<String> selectedDays;  // Add this field

StoreData({
    Map<String, List<TimeSlot>>? storeTimes, 
    this.availability = 'Available 24/7',
    List<String>? selectedDays,
  }) : 
    storeTimes = storeTimes ?? {
      'Monday': [], 'Tuesday': [], 'Wednesday': [], 'Thursday': [], 
      'Friday': [], 'Saturday': [], 'Sunday': []
    },
    selectedDays = selectedDays ?? [];
}

class StoreDataProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final StoreData _storeData = StoreData();
  StoreData get storeData => _storeData;
  Map<String, dynamic>? _business;
  String? _docId;
  Map<String, dynamic>? get business => _business;
  String? get docId => _docId;

  StreamSubscription<DocumentSnapshot>? _storeDataSubscription;

  StoreDataProvider() {
    _startListeningToStoreData();
  }

  void _startListeningToStoreData() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      _storeDataSubscription = _firestore
          .collection("bregisterbusiness")
          .where('uid', isEqualTo: uid)
          .limit(1)
          .snapshots()
          .listen(
        (querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            DocumentSnapshot doc = querySnapshot.docs.first;
            _docId = doc.id;
            _business = doc.data() as Map<String, dynamic>?;

            if (_business != null) {
              _storeData.availability = _business!['availability'] ?? 'Available 24/7';
              _storeData.storeTimes = _parseStoreTimes(_business!['storeTimes'] ?? {});
              _storeData.selectedDays = _getSelectedDaysFromStoreTimes(_storeData.storeTimes);
            }

            notifyListeners();
          }
        },
        onError: (error) {
          print('Error in store data stream: $error');
        },
      ) as StreamSubscription<DocumentSnapshot<Object?>>?;
    } catch (e) {
      print('Error setting up store data stream: $e');
    }
  }

  List<String> _getSelectedDaysFromStoreTimes(Map<String, List<TimeSlot>> storeTimes) {
    return storeTimes.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();
  }
  void updateSelectedDays(List<String> days) {
    _storeData.selectedDays = List.from(days);
    notifyListeners();
  }

  void updateStoreTimes(Map<String, List<TimeSlot>> times) {
    _storeData.storeTimes = Map.from(times);
    _storeData.selectedDays = _getSelectedDaysFromStoreTimes(times);
    saveStoreData();
  }

  void updateAvailability(String availability) {
    _storeData.availability = availability;
    saveStoreData();
    notifyListeners();
  }

  String getFormattedStoreTimes() {
    if (_storeData.availability == 'Available 24/7') {
      return 'Open 24/7';
    }

    List<String> formattedTimes = [];
    _storeData.storeTimes.forEach((day, slots) {
      if (slots.isNotEmpty) {
        String dayTimes = '$day: ';
        dayTimes += slots.map((slot) {
          if (slot.openTime == null || slot.closeTime == null) return '';
          return '${_formatTimeOfDay(slot.openTime)} - ${_formatTimeOfDay(slot.closeTime)}';
        }).where((time) => time.isNotEmpty).join(', ');
        if (dayTimes != '$day: ') {  // Only add if there are valid times
          formattedTimes.add(dayTimes);
        }
      }
    });

    return formattedTimes.join('\n');
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Add this method to update business data
  void updateBusiness(Map<String, dynamic> businessData, String docId) {
    _business = businessData;
    _docId = docId;
    notifyListeners();
  }

   Future<void> fetchStoreData() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('bregisterbusiness')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        _docId = doc.id;
        _business = doc.data() as Map<String, dynamic>?;
        
        // Update _storeData based on the fetched business data
        if (_business != null) {
          _storeData.availability = _business!['availability'] ?? 'Available 24/7';
          _storeData.storeTimes = _parseStoreTimes(_business!['storeTimes']);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching store data: $e');
    }
  }

  // New method to save store data
  Future<void> saveStoreData() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // Convert store times to a format that can be stored in Firestore
      Map<String, List<Map<String, dynamic>>> storeTimesMap = {};
      _storeData.storeTimes.forEach((day, slots) {
        if (slots.isNotEmpty) {
          storeTimesMap[day] = slots.map((slot) => slot.toMap()).toList();
        }
      });

      Map<String, dynamic> data = {
        'availability': _storeData.availability,
        'storeTimes': storeTimesMap,
        'selectedDays': _storeData.selectedDays,
      };

      if (_docId != null) {
        // Update existing document
        await _firestore.collection('bregisterbusiness').doc(_docId).update(data);
      }
      notifyListeners();
    } catch (e) {
      print('Error saving store data: $e');
    }
  }

  Map<String, List<TimeSlot>> _parseStoreTimes(Map<String, dynamic>? storeTimes) {
    Map<String, List<TimeSlot>> parsedTimes = {
      'Monday': [], 'Tuesday': [], 'Wednesday': [], 'Thursday': [], 
      'Friday': [], 'Saturday': [], 'Sunday': []
    };

    if (storeTimes != null) {
      storeTimes.forEach((day, slots) {
        if (slots is List) {
          parsedTimes[day] = slots
              .map((slot) => TimeSlot.fromMap(Map<String, dynamic>.from(slot)))
              .toList();
        }
      });
    }

    return parsedTimes;
  }

  Future<void> clearStoreData() async {
    try {
      // Clear local state
      _storeData.availability = 'Available 24/7';
      _storeData.storeTimes = {
        'Monday': [], 'Tuesday': [], 'Wednesday': [], 'Thursday': [],
        'Friday': [], 'Saturday': [], 'Sunday': []
      };
      _storeData.selectedDays = [];
      _business = null;

      // Clear data from Firestore
      if (_docId != null) {
        await _firestore.collection('bregisterbusiness').doc(_docId).delete();
        _docId = null;
      }

      // Cancel the existing subscription
      await _storeDataSubscription?.cancel();
      _storeDataSubscription = null;

      notifyListeners();
    } catch (e) {
      print('Error clearing store data: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _storeDataSubscription?.cancel();
    _storeDataSubscription = null;
    super.dispose();
  }
}