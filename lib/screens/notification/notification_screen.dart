import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/notification_service.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _service = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final data = await _service.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  void _subscribeRealtime() {
    _channel = _service.subscribeToNotifications((payload) {
      _loadNotifications();
    });
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    await _service.markAsRead(notificationId);
    if (mounted) {
      setState(() {
        _notifications[index]['is_read'] = true;
      });
    }
  }

  Future<void> _markAllAsRead(String type) async {
    await _service.markAllAsRead();
    if (mounted) {
      setState(() {
        for (var n in _notifications) {
          n['is_read'] = true;
        }
      });
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    await _service.deleteNotification(notificationId);
    if (mounted) {
      setState(() {
        _notifications.removeWhere((n) => n['notification_id'] == notificationId);
      });
    }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pisahkan notifikasi berdasarkan tipe
    final orderNotifs = _notifications
        .where((n) => n['notification_type']?.toString().toLowerCase() == 'order')
        .toList();
    final generalNotifs = _notifications
        .where((n) => n['notification_type']?.toString().toLowerCase() != 'order')
        .toList();
    final unreadOrderCount = orderNotifs.where((n) => n['is_read'] != true).length;
    final unreadGeneralCount = generalNotifs.where((n) => n['is_read'] != true).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 110,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 16),
          label: const Text(
            'Kembali',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Notifikasi',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada notifikasi',
                        style: AppTextStyles.subtitle.copyWith(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadNotifications,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ──── Pesanan Saya ────
                      if (orderNotifs.isNotEmpty)
                        _buildSection(
                          title: 'Pesanan Saya',
                          unreadCount: unreadOrderCount,
                          notifications: orderNotifs,
                          type: 'order',
                        ),
                      if (orderNotifs.isNotEmpty && generalNotifs.isNotEmpty)
                        const SizedBox(height: 16),
                      // ──── Notifikasi Umum ────
                      if (generalNotifs.isNotEmpty)
                        _buildSection(
                          title: 'Notifikasi Umum',
                          unreadCount: unreadGeneralCount,
                          notifications: generalNotifs,
                          type: 'general',
                        ),
                      // Jika semua notifikasi bertipe order dan tidak ada general
                      if (orderNotifs.isEmpty && generalNotifs.isNotEmpty)
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection({
    required String title,
    required int unreadCount,
    required List<Map<String, dynamic>> notifications,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.h2.copyWith(color: AppColors.text, fontWeight: FontWeight.w500, fontSize: 16),
              ),
              if (unreadCount > 0)
                GestureDetector(
                  onTap: () => _markAllAsRead(type),
                  child: Text(
                    'Tandai Sudah Dibaca ($unreadCount)',
                    style: AppTextStyles.link.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...notifications.asMap().entries.map((entry) {
            final notif = entry.value;
            final globalIndex = _notifications.indexOf(notif);
            final isRead = notif['is_read'] == true;
            final notifId = notif['notification_id'] as int;

            return Dismissible(
              key: Key('notif_$notifId'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) => _deleteNotification(notifId),
              child: GestureDetector(
                onTap: () {
                  if (!isRead) _markAsRead(notifId, globalIndex);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : const Color(0xFFF0FFF4),
                    border: Border.all(
                      color: isRead ? AppColors.divider : AppColors.primary.withOpacity(0.3),
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: type == 'order'
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.accent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          type == 'order' ? Icons.shopping_bag_outlined : Icons.notifications_none,
                          color: type == 'order' ? AppColors.primary : AppColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notif['title']?.toString() ?? 'Notifikasi',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif['message']?.toString() ?? '',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: AppColors.mutedText,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _timeAgo(notif['created_at']?.toString()),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 11,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
