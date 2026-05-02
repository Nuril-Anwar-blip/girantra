import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final _supabase = Supabase.instance.client;
  StreamSubscription<Position>? _positionSub;

  // Dipanggil oleh seller/kurir saat memulai pengiriman
  Future<void> startTracking(int transactionId) async {
    final sellerId = _supabase.auth.currentUser?.id;
    if (sellerId == null) return;

    // Minta izin lokasi
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return;

    // Insert atau upsert baris awal
    final pos = await Geolocator.getCurrentPosition();
    await _supabase.from('courier_locations').upsert({
      'transaction_id': transactionId,
      'courier_id': sellerId,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'heading': pos.heading,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'transaction_id');

    // Stream update setiap 5 detik
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) async {
          await _supabase
              .from('courier_locations')
              .update({
                'latitude': position.latitude,
                'longitude': position.longitude,
                'heading': position.heading,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('transaction_id', transactionId);
        });
  }

  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  // Stream realtime untuk buyer — otomatis update saat kurir bergerak
  Stream<Map<String, dynamic>?> watchCourierLocation(int transactionId) {
    return _supabase
        .from('courier_locations')
        .stream(primaryKey: ['location_id'])
        .eq('transaction_id', transactionId)
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }
}
