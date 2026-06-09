import 'package:supabase_flutter/supabase_flutter.dart';

class LogisticService {
  final _supabase = Supabase.instance.client;

  /// Create a new logistics record with current_status = 'pending'
  Future<void> createLogistic({
    required int transactionId,
    required String courierName,
    required String trackingNumber,
  }) async {
    await _supabase.from('logistics').insert({
      'transaction_id': transactionId,
      'courier_name': courierName,
      'tracking_number': trackingNumber,
      'current_status': 'pending',
    });
  }

  /// Update current_status by transaction_id
  Future<void> updateLogisticStatus(int transactionId, String status) async {
    await _supabase
        .from('logistics')
        .update({'current_status': status})
        .eq('transaction_id', transactionId);
  }

  /// Update multiple shipping fields (shippingDate, arrivalDate, status)
  Future<void> updateShippingInfo(
    int transactionId, {
    String? shippingDate,
    String? arrivalDate,
    String? status,
  }) async {
    final Map<String, dynamic> updates = {};
    if (shippingDate != null) updates['shipping_date'] = shippingDate;
    if (arrivalDate != null) updates['arrival_date'] = arrivalDate;
    if (status != null) updates['current_status'] = status;

    if (updates.isEmpty) return;

    await _supabase
        .from('logistics')
        .update(updates)
        .eq('transaction_id', transactionId);
  }

  /// Get logistics record for a specific transaction
  Future<Map<String, dynamic>?> getLogisticByTransactionId(
      int transactionId) async {
    try {
      final response = await _supabase
          .from('logistics')
          .select()
          .eq('transaction_id', transactionId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }
}
