import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../widgets/seller_product_card.dart';
import '../overlay/reject_order_dialog.dart';
import '../overlay/arrange_delivery_dialog.dart';

class DeliverySellerScreen extends StatefulWidget {
  const DeliverySellerScreen({super.key});

  @override
  State<DeliverySellerScreen> createState() => _DeliverySellerScreenState();
}

class _DeliverySellerScreenState extends State<DeliverySellerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _newOrders = [];
  List<Map<String, dynamic>> _processingOrders = [];
  List<Map<String, dynamic>> _shippedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) return;

      final response = await _supabase
          .from('transactions')
          .select('*, products(product_name, image_url, unit)')
          .eq('seller_id', sellerId)
          .order('transaction_date', ascending: false);

      final orders = List<Map<String, dynamic>>.from(response);

      if (mounted) {
        setState(() {
          // paid but no completed_date → new orders (belum diproses)
          _newOrders = orders.where((o) {
            final status = o['payment_status']?.toString() ?? '';
            final completed = o['completed_date'];
            return status == 'paid' && completed == null;
          }).toList();

          // pending payment → still processing
          _processingOrders = orders.where((o) {
            final status = o['payment_status']?.toString() ?? '';
            return status == 'pending';
          }).toList();

          // completed orders
          _shippedOrders = orders.where((o) {
            final completed = o['completed_date'];
            return completed != null;
          }).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading orders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptOrder(Map<String, dynamic> order) async {
    showDialog(
      context: context,
      builder: (_) => ArrangeDeliveryDialog(orderId: order['transaction_code']?.toString() ?? ''),
    );
  }

  Future<void> _rejectOrder(Map<String, dynamic> order) async {
    showDialog(
      context: context,
      builder: (_) => RejectOrderDialog(orderId: order['transaction_code']?.toString() ?? ''),
    );
  }

  String _formatCurrency(num amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Widget _buildCustomTab({
    required String label,
    required String count,
    required int index,
    required bool isSelected,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppColors.primary;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: isSelected ? color : Colors.grey.shade400, width: 2),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Text(
                label,
                style: AppTextStyles.subtitle.copyWith(
                  color: isSelected ? color : Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Positioned(
                top: 6,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.grey.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count,
                    style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, height: 1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pesanan Masuk', style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildCustomTab(label: 'Baru', count: '${_newOrders.length}', index: 0, isSelected: _tabController.index == 0),
                      const SizedBox(width: 8),
                      _buildCustomTab(label: 'Proses', count: '${_processingOrders.length}', index: 1, isSelected: _tabController.index == 1),
                      const SizedBox(width: 8),
                      _buildCustomTab(label: 'Dikirim', count: '${_shippedOrders.length}', index: 2, isSelected: _tabController.index == 2),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(_newOrders, _TabState.baru),
                      _buildOrderList(_processingOrders, _TabState.proses),
                      _buildOrderList(_shippedOrders, _TabState.dikirim),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders, _TabState tabState) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Belum ada pesanan', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order, tabState);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, _TabState tabState) {
    final product = order['products'] as Map<String, dynamic>? ?? {};
    final trxCode = order['transaction_code']?.toString() ?? '-';
    final productName = product['product_name']?.toString() ?? 'Produk';
    final imageUrl = product['image_url']?.toString() ?? '';
    final qty = order['quantity'] as int? ?? 1;
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0;
    final address = order['shipping_address']?.toString() ?? '-';

    Color statusColor;
    String statusText;
    switch (tabState) {
      case _TabState.baru:
        statusColor = AppColors.primaryDark;
        statusText = 'Baru';
        break;
      case _TabState.proses:
        statusColor = Colors.orange;
        statusText = 'Diproses';
        break;
      case _TabState.dikirim:
        statusColor = AppColors.primaryDark;
        statusText = 'Selesai';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SellerProductCard(
        imageUrl: imageUrl,
        title: productName,
        priceFormatted: _formatCurrency(totalAmount),
        statusText: statusText,
        statusColor: statusColor,
        topLabel: 'ID: $trxCode',
        customQuantityText: 'Jumlah: $qty',
        showProductStats: false,
        showButtons: tabState == _TabState.baru,
        secondaryActionText: tabState == _TabState.baru ? 'Tolak' : null,
        secondaryActionColor: Colors.red,
        primaryActionText: tabState == _TabState.baru ? 'Terima' : '',
        showPrimaryActionIcon: false,
        onPrimaryAction: () => _acceptOrder(order),
        onSecondaryAction: tabState == _TabState.baru ? () => _rejectOrder(order) : null,
        extraContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.location_on, color: Colors.orange, size: 16),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pengiriman ke', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 2),
                      Text(address, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            if (tabState != _TabState.baru) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(height: 2),
                        Text(
                          tabState == _TabState.proses ? 'Menunggu Pembayaran' : 'Pesanan Selesai',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _TabState { baru, proses, dikirim }
