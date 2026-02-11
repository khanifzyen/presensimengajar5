import 'package:presensimengajar_flutter/features/admin/data/models/misc_models.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<int> getUnreadCount(String userId);
}
