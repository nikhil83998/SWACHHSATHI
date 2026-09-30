import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unknown/utils/app_settings.dart';

class Locationpage extends StatefulWidget {
  const Locationpage({super.key});

  @override
  _LocationpageState createState() => _LocationpageState();
}

class _LocationpageState extends State<Locationpage> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  Marker? _marker;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location services are disabled. Please enable them.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Location permissions are permanently denied.';
          });
          return;
        }
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Location permissions are denied.';
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _marker = Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentLocation!,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              _currentLocation = newPosition;
            });
          },
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch location: $e';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _currentLocation = location;
      _marker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: location,
        draggable: true,
        onDragEnd: (LatLng newPosition) {
          setState(() {
            _currentLocation = newPosition;
          });
        },
      );
    });
  }

  void _saveLocation() {
    if (_currentLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location selected.')),
      );
    }
  }

  void _recenterMap() async {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppSettings.instance.tr('adjust_location')),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _recenterMap,
            tooltip: 'Recenter to current location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation ?? const LatLng(0, 0),
                          zoom: 15,
                        ),
                        markers: _marker != null ? {_marker!} : <Marker>{},
                        onTap: _onMapTapped,
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _saveLocation,
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              AppSettings.instance.tr('confirm_location'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark ? Colors.greenAccent : Colors.green,
                              foregroundColor:
                                  isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
