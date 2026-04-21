import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildCustomTab(
                  label: 'Baru',
                  count: '7',
                  index: 0,
                  isSelected: _tabController.index == 0,
                ),
                const SizedBox(width: 8),
                _buildCustomTab(
                  label: 'Proses',
                  count: '2',
                  index: 1,
                  isSelected: _tabController.index == 1,
                ),
                const SizedBox(width: 8),
                _buildCustomTab(
                  label: 'Dikirim',
                  count: '4',
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
                  itemCount: 2,
                  tabState: _TabState.baru,
                ),
                // TAB 2: Proses
                _buildTabContent(
                  title: 'Pesanan Diproses',
                  itemCount: 1,
                  tabState: _TabState.proses,
                ),
                // TAB 3: Dikirim
                _buildTabContent(
                  title: 'Pesanan Dikirim',
                  itemCount: 1,
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
    required int itemCount,
    required _TabState tabState,
  }) {
    return ListView(
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
        ...List.generate(itemCount, (index) {
          if (tabState == _TabState.baru && index == 1) {
            return _DeliveryCard(
              id: '#TRX-20260419034',
              title: 'Pupuk Kompos Organik',
              amount: 1,
              price: 'Rp 45.000',
              address: 'Jl. Adi Sucipto no. 44, Laweyan, Kota Surakarta',
              tabState: tabState,
            );
          }
          return _DeliveryCard(
            id: '#TRX-20260419001',
            title: 'Bibit Padi Unggul',
            amount: 6,
            price: 'Rp 255.000',
            address:
                'Jl. Jendral Sudirman no.34, Jakarta Selatan, Indonesia...',
            tabState: tabState,
          );
        }),
      ],
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

  const _DeliveryCard({
    required this.id,
    required this.title,
    required this.amount,
    required this.price,
    required this.address,
    required this.tabState,
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
      imageUrl: '', // default placeholder
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
      primaryActionText: tabState == _TabState.baru 
          ? 'Terima' 
          : '',
      showPrimaryActionIcon: false,
      onPrimaryAction: () {
        showDialog(
          context: context,
          builder: (_) => ArrangeDeliveryDialog(orderId: id),
        );
      },
      onSecondaryAction: tabState == _TabState.baru ? () {
        showDialog(
          context: context,
          builder: (_) => RejectOrderDialog(orderId: id),
        );
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ArrangeDeliveryDialog(orderId: id),
                      );
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
                    child: const Text('Atur Kirim', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
