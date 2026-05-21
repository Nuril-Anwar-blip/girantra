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
        title: const Text(
          'Pilih Koordinat Alamat',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          _currentPos == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF358C36),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(target: _currentPos!, zoom: 15),
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _selectedMarker != null ? {_selectedMarker!} : {},
                  onTap: _onTap,
                ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF358C36), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedMarker == null
                          ? 'Ketuk pada peta untuk memilih lokasi pengiriman yang akurat.'
                          : 'Lokasi terpilih! Anda bisa mengetuk area lain untuk mengubah.',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF358C36),
        label: const Text(
          'Konfirmasi Lokasi',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
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
