import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? _selectedLocation;
  String? _address;

  LatLng? get selectedLocation => _selectedLocation;
  String? get address => _address;

  void setLocation(LatLng location, String address) {
    _selectedLocation = location;
    _address = address;
    notifyListeners();
  }

   void setAddressOnly(String address) {
    _address = address;
    notifyListeners();
  }

  void clearLocation() {
    _selectedLocation = null;
    _address = null;
    notifyListeners();
  }
}