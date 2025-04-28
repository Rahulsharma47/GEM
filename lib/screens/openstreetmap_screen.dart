// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class OpenStreetMapPage extends StatefulWidget {
  const OpenStreetMapPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OpenStreetMapPageState createState() => _OpenStreetMapPageState();
}

class _OpenStreetMapPageState extends State<OpenStreetMapPage> {
  LatLng _currentPosition = const LatLng(51.509364, -0.128928);
  final MapController _mapController = MapController();
  String _address = '';
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _startTrackingLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // Keeping all the existing methods unchanged
  Future<void> _getAddress(LatLng position) async {
  try {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';
    
    // Add a delay to respect API rate limits
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'YourApp/1.0', // Nominatim requires a User-Agent header
      },
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        _address = data['display_name'] ?? 'Address not found';
      });
    } else {
      setState(() {
        _address = 'Failed to get address';
      });
    }
  } catch (e) {
    print('Error getting address: $e');
    setState(() {
      _address = 'Error fetching address';
    });
  }
}

  Future<void> _startTrackingLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition, 13);
        _getAddress(_currentPosition);
      });
    }
  }

  Future<void> _searchLocation(String query) async {
  if (query.isEmpty) return;

  try {
    // Show some loading indicator
    setState(() {
      _address = 'Searching...';
    });

    // Encode the query parameters properly
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://nominatim.openstreetmap.org/search?format=json&q=$encodedQuery&limit=1';
    
    // Add delay to respect rate limiting
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'YourApp/1.0', // Required by Nominatim
      },
    );

    print('Search Response Status: ${response.statusCode}');
    print('Search Response Body: ${response.body}');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.tryParse(data[0]['lat']);
        final lon = double.tryParse(data[0]['lon']);
        
        if (lat != null && lon != null) {
          setState(() {
            _currentPosition = LatLng(lat, lon);
          });
          
          // Animate to the new position
          _mapController.move(_currentPosition, 13);
          
          // Get the address for the new position
          await _getAddress(_currentPosition);
          
          // Clear the search field
          _searchController.clear();
        } else {
          setState(() {
            _address = 'Invalid location data received';
          });
        }
      } else {
        setState(() {
          _address = 'No results found';
        });
      }
    } else {
      setState(() {
        _address = 'Search failed. Please try again';
      });
    }
  } catch (e) {
    print('Search error: $e');
    setState(() {
      _address = 'Error during search';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition,
              zoom: 13.0,
              onTap: (_, point) async {
                setState(() {
                  _currentPosition = point;
                });
                await _getAddress(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 80.0,
                    height: 80.0,
                    builder: (ctx) => const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Search bar with improved styling
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a location',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.grey),
                    onPressed: () => _searchLocation(_searchController.text),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: _searchLocation,
              ),
            ),
          ),
          // Bottom container with address and buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _address,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // GPS button integrated in the address container
                        IconButton(
                          onPressed: () async {
                            try {
                              Position position = await Geolocator.getCurrentPosition(
                                  // ignore: deprecated_member_use
                                  desiredAccuracy: LocationAccuracy.high);
                              LatLng currentPosition = LatLng(
                                  position.latitude, position.longitude);
                              setState(() {
                                _currentPosition = currentPosition;
                              });
                              _mapController.move(_currentPosition, 13);
                              _getAddress(_currentPosition);
                            } catch (e) {
                              print("Error getting current location: $e");
                            }
                          },
                          icon: const Icon(Icons.my_location),
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'location': _currentPosition,
                            'address': _address,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}