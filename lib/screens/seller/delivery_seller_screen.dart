import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../../widgets/seller_product_card.dart';
import '../overlay/reject_order_dialog.dart';
import '../overlay/arrange_delivery_dialog.dart';
import '../overlay/kirim_pesanan_dialog.dart';

class DeliverySellerScreen extends StatefulWidget {
  const DeliverySellerScreen({super.key});

  @override
  State<DeliverySellerScreen> createState() => _DeliverySellerScreenState();
}

class _DeliverySellerScreenState extends State<DeliverySellerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _baru = [];
  List<Map<String, dynamic>> _proses = [];
  List<Map<String, dynamic>> _dikirim = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) throw Exception('Tidak ada user yang login');

      final response = await _supabase
          .from('transactions')
          .select('''
            *,
            products (
              product_name,
              image_url,
              selling_price,
              stock
            ),
            logistics (
              current_status,
              tracking_number,
              courier_name
            )
          ''')
          .eq('seller_id', sellerId)
          .eq('payment_status', 'paid')
          .order('transaction_date', ascending: false);

      if (!mounted) return;
      setState(() {
        _baru = [];
        _proses = [];
        _dikirim = [];

        for (final o in response) {
          final logisticsData = o['logistics'];
          String? currentStatus;
          String? arrivalDateStr;
          
          if (logisticsData != null) {
            if (logisticsData is List && logisticsData.isNotEmpty) {
              // Asumsi ambil data logistik terbaru jika ada lebih dari 1
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

          if (currentStatus == null || currentStatus == 'pending') {
            _baru.add(o);
          } else if (currentStatus == 'processing' || currentStatus == 'packed') {
            _proses.add(o);
          } else if (currentStatus == 'delivery' || currentStatus == 'on_delivery' || currentStatus == 'delivered') {
            _dikirim.add(o);
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading seller orders: $e');
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
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? color : Colors.grey.shade400,
                width: 2,
              ),
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
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
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
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
        title: Text(
          'Pesanan Masuk',
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _buildCustomTab(
                            label: 'Baru',
                            count: _baru.length.toString(),
                            index: 0,
                            isSelected: _tabController.index == 0,
                          ),
                          const SizedBox(width: 8),
                          _buildCustomTab(
                            label: 'Proses',
                            count: _proses.length.toString(),
                            index: 1,
                            isSelected: _tabController.index == 1,
                          ),
                          const SizedBox(width: 8),
                          _buildCustomTab(
                            label: 'Dikirim',
                            count: _dikirim.length.toString(),
                            index: 2,
                            isSelected: _tabController.index == 2,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // TAB 1: Baru
                          _buildTabContent(
                            title: 'Pesanan Baru',
                            items: _baru,
                            tabState: _TabState.baru,
                          ),
                          // TAB 2: Proses
                          _buildTabContent(
                            title: 'Pesanan Diproses',
                            items: _proses,
                            tabState: _TabState.proses,
                          ),
                          // TAB 3: Dikirim
                          _buildTabContent(
                            title: 'Pesanan Dikirim',
                            items: _dikirim,
                            tabState: _TabState.dikirim,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTabContent({
    required String title,
    required List<Map<String, dynamic>> items,
    required _TabState tabState,
  }) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: const Center(
                child: Text('Belum ada pesanan'),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((order) {
            final product = order['products'] as Map<String, dynamic>?;
            final productName = product?['product_name']?.toString() ?? 'Produk';
            final imageUrl = product?['image_url']?.toString() ?? '';
            final price = _formatPrice(order['sub_total'] ?? order['total_price'] ?? 0);
            final amount = order['quantity'] ?? order['qty'] ?? 1;
            final address = order['shipping_address']?.toString() ?? order['address']?.toString() ?? '-';
            final id = _formatOrderId(order['transaction_code'] ?? order['transaction_id']);
            final transactionIdDb = order['transaction_id'];
            final productId = order['product_id'];
            final currentStock = product?['stock'] is int ? product!['stock'] as int : int.tryParse(product?['stock']?.toString() ?? '0') ?? 0;

            String trackingNumber = '';
            if (order['logistics'] != null) {
              final logData = order['logistics'];
              if (logData is List && logData.isNotEmpty) {
                trackingNumber = logData.last['tracking_number']?.toString() ?? '';
              } else if (logData is Map) {
                trackingNumber = logData['tracking_number']?.toString() ?? '';
              }
            }

            return _DeliveryCard(
              id: id,
              transactionIdDb: transactionIdDb,
              trackingNumber: trackingNumber,
              title: productName,
              amount: amount,
              price: price,
              address: address,
              tabState: tabState,
              imageUrl: imageUrl,
              productId: productId,
              currentStock: currentStock,
              onRefresh: _loadOrders,
            );
          }),
        ],
      ),
    );
  }
}

enum _TabState { baru, proses, dikirim }

class _DeliveryCard extends StatelessWidget {
  final String id;
  final String title;
  final int amount;
  final String price;
  final String address;
  final _TabState tabState;
  final String imageUrl;
  final dynamic transactionIdDb;
  final String trackingNumber;
  final VoidCallback onRefresh;
  final dynamic productId;
  final int currentStock;

  const _DeliveryCard({
    required this.id,
    required this.title,
    required this.amount,
    required this.price,
    required this.address,
    required this.tabState,
    required this.imageUrl,
    required this.transactionIdDb,
    required this.trackingNumber,
    required this.productId,
    required this.currentStock,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
        statusText = 'Dikirim';
        break;
    }

    return SellerProductCard(
      imageUrl: imageUrl,
      title: title,
      priceFormatted: price,
      statusText: statusText,
      statusColor: statusColor,
      topLabel: 'ID: $id',
      customQuantityText: 'Jumlah: $amount',
      showProductStats: false,
      showButtons: tabState == _TabState.baru,
      secondaryActionText: tabState == _TabState.baru ? 'Tolak' : null,
      secondaryActionColor: Colors.red,
      primaryActionText: tabState == _TabState.baru ? 'Terima' : '',
      showPrimaryActionIcon: false,
      onPrimaryAction: tabState == _TabState.baru ? () async {
        final courierName = await showDialog<String>(
          context: context,
          builder: (_) => ArrangeDeliveryDialog(
            orderId: id,
            productName: title,
            quantity: amount,
            destinationAddress: address,
          ),
        );
        
        if (courierName != null) {
          try {
            final supabase = Supabase.instance.client;
            
            if (transactionIdDb != null) {
              await supabase.from('logistics').insert({
                'transaction_id': transactionIdDb,
                'current_status': 'processing', 
                'courier_name': courierName,
                'tracking_number': 'DELIV-${DateTime.now().millisecondsSinceEpoch}',
                'created_at': DateTime.now().toUtc().toIso8601String(),
              });

              if (productId != null) {
                final newStock = (currentStock - amount) < 0 ? 0 : (currentStock - amount);
                final newStatus = newStock > 0 ? 'available' : 'out_of_stock';
                await supabase.from('products').update({
                  'stock': newStock,
                  'status_product': newStatus
                }).eq('product_id', productId);
              }
            } else {
              throw Exception('ID Transaksi tidak ditemukan');
            }

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil diterima dan masuk ke Proses')));
            onRefresh();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal terima pesanan: $e')));
          }
        }
      } : null,
      onSecondaryAction: tabState == _TabState.baru ? () async {
        final result = await showDialog(
          context: context,
          builder: (_) => RejectOrderDialog(orderId: id),
        );
        // Jika dialog mereturn true/berhasil tolak, kita refresh
        if (result == true) {
          onRefresh();
        }
      } : null,
      extraContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on,
                  color: Colors.orange,
                  size: 16,
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengiriman ke',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tabState != _TabState.baru) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kurir',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pengiriman Mandiri (Anda)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (tabState != _TabState.baru) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tabState == _TabState.proses
                            ? 'Sedang dalam Pengemasan'
                            : 'Sedang dalam Pengiriman',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tabState == _TabState.proses
                              ? Colors.orange
                              : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tabState == _TabState.proses)
                  ElevatedButton(
                    onPressed: () async {
                      final arrivalDate = await showDialog<DateTime>(
                        context: context,
                        builder: (_) => KirimPesananDialog(
                          orderId: id,
                          trackingNumber: trackingNumber,
                        ),
                      );
                      
                      if (arrivalDate != null) {
                        try {
                          final supabase = Supabase.instance.client;
                          
                          if (transactionIdDb != null) {
                            await supabase.from('logistics').update({
                              'current_status': 'delivery',
                              'shipping_date': DateTime.now().toUtc().toIso8601String(),
                              'arrival_date': arrivalDate.toUtc().toIso8601String(),
                            }).eq('transaction_id', transactionIdDb);
                          } else {
                              throw Exception('ID Transaksi tidak ditemukan');
                          }
                
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil diatur pengirimannya (Dikirim)')));
                          onRefresh();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal atur kirim: $e')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text('Kirim Pesanan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
