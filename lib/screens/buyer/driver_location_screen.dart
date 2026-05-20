import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationScreen extends StatefulWidget {
  const DriverLocationScreen({super.key});

  @override
  State<DriverLocationScreen> createState() => _DriverLocationScreenState();
}

class _DriverLocationScreenState extends State<DriverLocationScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentPos;
  Marker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPos = LatLng(pos.latitude, pos.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng point) {
    setState(() {
      _selectedMarker = Marker(markerId: const MarkerId('selected'), position: point);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Driver / Pilih Alamat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _currentPos == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(target: _currentPos!, zoom: 14),
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              markers: _selectedMarker != null ? {_selectedMarker!} : {},
              onTap: _onTap,
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Pilih Lokasi Ini'),
        icon: const Icon(Icons.check),
        onPressed: () {
          if (_selectedMarker != null) {
            Navigator.of(context).pop(_selectedMarker!.position);
          } else if (_currentPos != null) {
            Navigator.of(context).pop(_currentPos);
          }
        },
      ),
    );
  }
}
