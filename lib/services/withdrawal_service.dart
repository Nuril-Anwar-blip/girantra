import 'package:supabase_flutter/supabase_flutter.dart';

class WithdrawalService {
  final _supabase = Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get current seller's wallet balance from wallets table.
  /// Returns 0.0 if no wallet record is found.
  Future<double> getWalletBalance() async {
    final userId = _userId;
    if (userId == null) throw Exception('User tidak terautentikasi');

    final response = await _supabase
        .from('wallets')
        .select('balance')
        .eq('seller_id', userId)
        .maybeSingle();

    if (response == null) return 0.0;

    final balance = response['balance'];
    if (balance == null) return 0.0;
    return double.tryParse(balance.toString()) ?? 0.0;
  }

  /// Fetch all withdrawals for the current seller, ordered by created_at desc.
  Future<List<Map<String, dynamic>>> getWithdrawalHistory() async {
    final userId = _userId;
    if (userId == null) throw Exception('User tidak terautentikasi');

    final response = await _supabase
        .from('withdrawals')
        .select()
        .eq('seller_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Request a withdrawal. Checks if balance >= amount, then updates the wallet
  /// balance and inserts a withdrawal record. Returns true on success.
  /// Throws an Exception with a message if the balance is insufficient.
  Future<bool> requestWithdrawal({
    required double amount,
    required String bankName,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User tidak terautentikasi');

    if (amount <= 0) throw Exception('Jumlah penarikan harus lebih dari 0');

    // Step 1: Get current balance
    final walletResponse = await _supabase
        .from('wallets')
        .select('balance')
        .eq('seller_id', userId)
        .maybeSingle();

    if (walletResponse == null) {
      throw Exception('Wallet tidak ditemukan');
    }

    final currentBalance =
        double.tryParse(walletResponse['balance'].toString()) ?? 0.0;

    // Step 2: Check sufficient balance
    if (currentBalance < amount) {
      throw Exception(
        'Saldo tidak mencukupi. Saldo saat ini: Rp ${_formatNumber(currentBalance)}',
      );
    }

    // Step 3: Update wallet balance (subtract amount)
    final newBalance = currentBalance - amount;
    await _supabase
        .from('wallets')
        .update({
          'balance': newBalance,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('seller_id', userId);

    // Step 4: Insert withdrawal record
    await _supabase.from('withdrawals').insert({
      'seller_id': userId,
      'amount': amount,
      'bank_name': bankName,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    return true;
  }

  String _formatNumber(double number) {
    final parts = number.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }
}
