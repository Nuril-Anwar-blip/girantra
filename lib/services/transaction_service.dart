import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Select string for transaction joins
  static const String _selectWithJoins =
      '*, products(product_name, image_url, unit), '
      'users!fk_transactions_seller(full_name), '
      'logistics(*)';

  static const String _selectWithBuyerJoin =
      '*, products(product_name, image_url, unit), '
      'users!fk_transactions_buyer(full_name), '
      'logistics(*)';

  /// Get all transactions for current buyer, ordered by transaction_date desc
  Future<List<Map<String, dynamic>>> getBuyerTransactions() async {
    if (_userId == null) return [];
    try {
      final response = await _supabase
          .from('transactions')
          .select(_selectWithJoins)
          .eq('buyer_id', _userId!)
          .order('transaction_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Get all transactions for current seller, ordered by transaction_date desc
  Future<List<Map<String, dynamic>>> getSellerTransactions() async {
    if (_userId == null) return [];
    try {
      final response = await _supabase
          .from('transactions')
          .select(_selectWithBuyerJoin)
          .eq('seller_id', _userId!)
          .order('transaction_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Get a single transaction by ID with all joins
  Future<Map<String, dynamic>?> getTransactionById(int transactionId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('$_selectWithJoins, users!fk_transactions_buyer(full_name)')
          .eq('transaction_id', transactionId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Update payment_status for a transaction
  Future<void> updatePaymentStatus(int transactionId, String status) async {
    await _supabase
        .from('transactions')
        .update({'payment_status': status})
        .eq('transaction_id', transactionId);
  }

  /// Get seller transactions filtered by payment_status
  Future<List<Map<String, dynamic>>> getSellerTransactionsByStatus(
      String paymentStatus) async {
    if (_userId == null) return [];
    try {
      final response = await _supabase
          .from('transactions')
          .select(_selectWithBuyerJoin)
          .eq('seller_id', _userId!)
          .eq('payment_status', paymentStatus)
          .order('transaction_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
