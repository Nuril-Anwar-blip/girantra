import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../widgets/seller_product_card.dart';
import 'payment_screen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _errorMessage;

  // Data per tab
  List<Map<String, dynamic>> _belumBayar = [];
  List<Map<String, dynamic>> _dikemas = [];
  List<Map<String, dynamic>> _dikirim = [];
  List<Map<String, dynamic>> _diterima = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Mapping status DB ke tab ──────────────────────────────────────────────
  // Sesuaikan nilai ini dengan enum/status yang ada di database Anda
  static const _statusBelumBayar = ['pending', 'paid', 'rejected'];
  static const _statusDikemas    = ['processing', 'packed'];
  static const _statusDikirim    = ['shipped', 'on_delivery'];
  static const _statusDiterima   = ['delivered', 'completed'];

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final buyerId = _supabase.auth.currentUser?.id;
      if (buyerId == null) throw Exception('Tidak ada user yang login');

      // Ambil semua order milik buyer ini beserta detail produk
      final response = await _supabase
          .from('transactions')
          .select('''
            *,
            products (
              *
            ),
            logistics (
              *
            )
          ''')
          .eq('buyer_id', buyerId)
          .order('transaction_date', ascending: false);

      if (!mounted) return;
      setState(() {
        _belumBayar = [];
        _dikemas = [];
        _dikirim = [];
        _diterima = [];

        for (final o in response) {
          final paymentStatus = (o['payment_status'] ?? o['status'] ?? o['transaction_status'])?.toString();
          
          final logisticsData = o['logistics'];
          String? currentStatus;
          String? arrivalDateStr;
          if (logisticsData != null) {
            if (logisticsData is List && logisticsData.isNotEmpty) {
              currentStatus = logisticsData.last['current_status']?.toString();
              arrivalDateStr = logisticsData.last['arrival_date']?.toString();
            } else if (logisticsData is Map) {
              currentStatus = logisticsData['current_status']?.toString();
              arrivalDateStr = logisticsData['arrival_date']?.toString();
            }
          }

          if (currentStatus == 'delivery' && arrivalDateStr != null) {
            final arrivalDate = DateTime.tryParse(arrivalDateStr);
            // Cek apakah tanggal saat ini sudah melewati hari kedatangan
            if (arrivalDate != null && DateTime.now().isAfter(arrivalDate.add(const Duration(days: 1)))) {
              currentStatus = 'received';
              final txId = o['transaction_code'] ?? o['transaction_id'] ?? o['id'];
              if (txId != null) {
                // Update ke database di background
                _supabase.from('logistics').update({'current_status': 'received'}).eq('transaction_id', txId).catchError((_) => null);
              }
            }
          }

          if (paymentStatus == 'pending' || paymentStatus == 'failed' || paymentStatus == 'rejected' || paymentStatus == null) {
            _belumBayar.add(o);
          } else if (paymentStatus == 'paid') {
            if (currentStatus == null || currentStatus == 'pending') {
              _belumBayar.add(o); // Menunggu seller klik Terima
            } else if (currentStatus == 'processing' || currentStatus == 'packed') {
              _dikemas.add(o);
            } else if (currentStatus == 'delivery' || currentStatus == 'on_delivery') {
              _dikirim.add(o);
            } else if (currentStatus == 'delivered' || currentStatus == 'completed') {
              _diterima.add(o);
            } else {
              _belumBayar.add(o);
            }
          }
        }

        _isLoading  = false;
      });
    } catch (e) {
      print('❌ Error loading orders: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat pesanan: $e';
        _isLoading = false;
      });
    }
  }

  String _formatPrice(dynamic price) {
    final p = price is double ? price : double.tryParse(price?.toString() ?? '0') ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(p);
  }

  String _formatOrderId(dynamic id) {
    if (id == null) return '#TRX-UNKNOWN';
    final str = id.toString();
    if (str.startsWith('TRX-') || str.startsWith('#')) return str;
    return '#TRX-$str';
  }

  // ── Tab styling helpers ───────────────────────────────────────────────────
  Widget _buildTabLabel(String text, int index) {
    final isActive = _tabController.index == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
          color: isActive ? AppColors.primary : Colors.grey.shade600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Pesanan Saya',
          style: AppTextStyles.h2.copyWith(color: AppColors.text, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelPadding: EdgeInsets.zero,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              dividerColor: Colors.grey.shade200,
              splashFactory: NoSplash.splashFactory,
              tabs: [
                Tab(child: _buildTabLabel('Belum Bayar', 0)),
                Tab(child: _buildTabLabel('Dikemas', 1)),
                Tab(child: _buildTabLabel('Dikirim', 2)),
                Tab(child: _buildTabLabel('Diterima', 3)),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBelumBayarTab(),
                    _buildDikemasTab(),
                    _buildDikirimTab(),
                    _buildDiterimaTab(),
                  ],
                ),
    );
  }

  // ── Tab: Belum Bayar ──────────────────────────────────────────────────────
  Widget _buildBelumBayarTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: _belumBayar.isEmpty
            ? _buildEmptyState(Icons.receipt_long_outlined, 'Belum ada pesanan')
            : Column(
                children: _belumBayar.map((order) {
                  final status = (order['payment_status'] ?? order['status'] ?? order['transaction_status'])?.toString() ?? '';
                  String statusLabel;
                  Color statusColor;
                  if (status == 'paid') {
                    statusLabel = 'Telah Dibayar';
                    statusColor = AppColors.primary;
                  } else if (status == 'rejected') {
                    statusLabel = 'Pembayaran Ditolak';
                    statusColor = Colors.red;
                  } else {
                    statusLabel = 'Belum Bayar';
                    statusColor = Colors.orange;
                  }
                  return GestureDetector(
                    onTap: status == 'paid' ? null : () {
                      final transactionId = order['transaction_code']?.toString() ?? order['transaction_id']?.toString() ?? order['id']?.toString() ?? '';
                      final amount = order['total_amount'] ?? order['total_price'] ?? 0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            transactionId: transactionId,
                            amount: amount,
                          ),
                        ),
                      );
                    },
                    child: _buildOrderCard(
                      order: order,
                      statusText: statusLabel,
                      statusColor: statusColor,
                      extraContent: null,
                      showButtons: false,
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  // ── Tab: Dikemas ──────────────────────────────────────────────────────────
  Widget _buildDikemasTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: _dikemas.isEmpty
            ? _buildEmptyState(Icons.inventory_2_outlined, 'Tidak ada pesanan yang sedang dikemas')
            : Column(
                children: _dikemas.map((order) => _buildOrderCard(
                  order: order,
                  statusText: 'Diproses',
                  statusColor: AppColors.accent,
                  showButtons: false,
                  extraContent: _buildStatusRow(
                    label: 'Status',
                    value: 'Sedang dalam Pengemasan',
                    valueColor: Colors.orange,
                  ),
                )).toList(),
              ),
      ),
    );
  }

  // ── Tab: Dikirim ──────────────────────────────────────────────────────────
  Widget _buildDikirimTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: _dikirim.isEmpty
            ? _buildEmptyState(Icons.local_shipping_outlined, 'Tidak ada pesanan yang sedang dikirim')
            : Column(
                children: _dikirim.map((order) {
                  final logistics = order['logistics'];
                  Map<String, dynamic>? logData;
                  if (logistics is List && logistics.isNotEmpty) {
                    logData = logistics.last;
                  } else if (logistics is Map) {
                    logData = logistics as Map<String, dynamic>;
                  }
                  
                  final courier = logData?['courier_name']?.toString() ?? 'Pengiriman Mandiri (Anda)';
                  final trackingNumber = logData?['tracking_number']?.toString() ?? '-';
                  final arrivalDateStr = logData?['arrival_date']?.toString();
                  String estimasi = '-';
                  if (arrivalDateStr != null) {
                    final date = DateTime.tryParse(arrivalDateStr);
                    if (date != null) {
                      estimasi = DateFormat('dd MMMM yyyy').format(date);
                    }
                  }

                  return _buildOrderCard(
                    order: order,
                    statusText: '', // Sembunyikan status text default agar tidak double
                    statusColor: Colors.transparent,
                    showButtons: false,
                    extraContent: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Kurir', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(height: 2),
                                  Text(courier, style: AppTextStyles.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('No Resi', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(height: 2),
                                  Text(trackingNumber, style: AppTextStyles.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(height: 2),
                                  Text('Sedang dalam Pengiriman', style: AppTextStyles.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Estimasi Sampai', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(height: 2),
                                  Text(estimasi, style: AppTextStyles.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  // ── Tab: Diterima ─────────────────────────────────────────────────────────
  Widget _buildDiterimaTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: _diterima.isEmpty
            ? _buildEmptyState(Icons.check_circle_outline, 'Belum ada pesanan yang diterima')
            : Column(
                children: _diterima.map((order) => _buildOrderCard(
                  order: order,
                  statusText: 'Diterima',
                  statusColor: AppColors.primary,
                  showButtons: false,
                  extraContent: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusRow(
                        label: 'Kurir',
                        value: order['courier_name']?.toString() ?? 'Pengiriman Mandiri (Anda)',
                        valueColor: AppColors.text,
                        valueBold: true,
                      ),
                      const SizedBox(height: 8),
                      _buildStatusRow(
                        label: 'Status',
                        value: 'Paket telah Diterima',
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                )).toList(),
              ),
      ),
    );
  }

  // ── Card builder ──────────────────────────────────────────────────────────
  Widget _buildOrderCard({
    required Map<String, dynamic> order,
    required String statusText,
    required Color statusColor,
    required bool showButtons,
    Widget? extraContent,
  }) {
    final product      = order['products'] as Map<String, dynamic>?;
    final productName  = product?['product_name']?.toString() ?? 'Produk';
    final imageUrl     = product?['image_url']?.toString() ?? '';
    final price        = _formatPrice(order['total_amount'] ?? order['total_price'] ?? 0);
    final quantity     = order['quantity'] ?? order['qty'] ?? 0;
    final shippingAddress      = order['shipping_address']?.toString() ??
                        order['address']?.toString() ?? '-';
    final transactionCode = _formatOrderId(order['transaction_code'] ?? order['id']);

    return SellerProductCard(
      imageUrl: imageUrl,
      title: productName,
      priceFormatted: price,
      statusText: statusText,
      statusColor: statusColor,
      showProductStats: false,
      showButtons: showButtons,
      customQuantityText: 'Jumlah: $quantity',
      topLabel: 'ID: $transactionCode',

      // Extra content: alamat + info tambahan per tab
      extraContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alamat pengiriman
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.orange),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengiriman ke',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      shippingAddress,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: AppColors.text,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Info tambahan per tab
          if (extraContent != null) ...[
            const SizedBox(height: 6),
            extraContent,
          ],
        ],
      ),
    );
  }

  // ── Status row (label + value) ────────────────────────────────────────────
  Widget _buildStatusRow({
    required String label,
    required String value,
    required Color valueColor,
    bool valueBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: valueColor,
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty & Error states ──────────────────────────────────────────────────
  Widget _buildEmptyState(IconData icon, String message) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.subtitle.copyWith(
                  color: Colors.grey.shade400, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 56, color: Colors.red.shade200),
          const SizedBox(height: 12),
          Text(_errorMessage!, style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            label: Text('Coba Lagi', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
