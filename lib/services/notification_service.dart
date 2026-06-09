import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Ambil semua notifikasi untuk user saat ini, urut terbaru
  Future<List<Map<String, dynamic>>> getNotifications() async {
    if (_userId == null) return [];
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Hitung jumlah notifikasi yang belum dibaca
  Future<int> getUnreadCount() async {
    if (_userId == null) return 0;
    try {
      final response = await _supabase
          .from('notifications')
          .select('notification_id')
          .eq('user_id', _userId!)
          .eq('is_read', false);
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<void> markAsRead(int notificationId) async {
    if (_userId == null) return;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('notification_id', notificationId)
        .eq('user_id', _userId!);
  }

  /// Tandai semua notifikasi user sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', _userId!)
        .eq('is_read', false);
  }

  /// Hapus satu notifikasi
  Future<void> deleteNotification(int notificationId) async {
    if (_userId == null) return;
    await _supabase
        .from('notifications')
        .delete()
        .eq('notification_id', notificationId)
        .eq('user_id', _userId!);
  }

  /// Subscribe ke perubahan realtime pada tabel notifications untuk user ini
  RealtimeChannel subscribeToNotifications(Function callback) {
    final channel = _supabase
        .channel('notifications_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _userId ?? '',
          ),
          callback: (payload) {
            callback(payload);
          },
        )
        .subscribe();
    return channel;
  }
}
