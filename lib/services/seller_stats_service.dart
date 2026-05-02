// lib/services/seller_stats_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SellerStatsService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getDashboardStats() async {
    final sellerId = _supabase.auth.currentUser?.id;
    if (sellerId == null) return {};

    // Total revenue dari transaksi yang sudah paid
    final revenue = await _supabase
        .from('transactions')
        .select('total_amount')
        .eq('seller_id', sellerId)
        .eq('payment_status', 'paid');

    // Order counts by status
    final orders = await _supabase
        .from('transactions')
        .select('order_status')
        .eq('seller_id', sellerId);

    // Produk aktif
    final products = await _supabase
        .from('products')
        .select('product_id, status_product')
        .eq('seller_id', sellerId);

    // Revenue 7 hari terakhir untuk grafik
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final weeklyRevenue = await _supabase
        .from('transactions')
        .select('total_amount, transaction_date')
        .eq('seller_id', sellerId)
        .eq('payment_status', 'paid')
        .gte('transaction_date', sevenDaysAgo.toIso8601String());

    double totalRevenue = 0;
    for (final r in revenue) {
      totalRevenue += (r['total_amount'] as num?)?.toDouble() ?? 0;
    }

    int pendingOrders = orders
        .where((o) => o['order_status'] == 'pending')
        .length;
    int processingOrders = orders
        .where((o) => o['order_status'] == 'processing')
        .length;
    int completedOrders = orders
        .where((o) => o['order_status'] == 'completed')
        .length;

    // Group weekly revenue by day
    final Map<String, double> dailyRevenue = {};
    for (var i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final key = '${day.day}/${day.month}';
      dailyRevenue[key] = 0;
    }
    for (final r in weeklyRevenue) {
      final date = DateTime.parse(r['transaction_date'].toString());
      final key = '${date.day}/${date.month}';
      if (dailyRevenue.containsKey(key)) {
        dailyRevenue[key] =
            (dailyRevenue[key] ?? 0) +
            ((r['total_amount'] as num?)?.toDouble() ?? 0);
      }
    }

    return {
      'total_revenue': totalRevenue,
      'pending_orders': pendingOrders,
      'processing_orders': processingOrders,
      'completed_orders': completedOrders,
      'total_orders': orders.length,
      'active_products': products
          .where((p) => p['status_product'] == 'available')
          .length,
      'weekly_revenue': dailyRevenue,
    };
  }
}
