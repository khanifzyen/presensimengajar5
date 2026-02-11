import 'package:pocketbase/pocketbase.dart';
import 'package:presensimengajar_flutter/core/constants/app_constants.dart';
import 'package:presensimengajar_flutter/features/notification/domain/repositories/notification_repository.dart';
import 'package:presensimengajar_flutter/features/admin/data/models/misc_models.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final PocketBase pb;

  NotificationRepositoryImpl(this.pb);

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final records = await pb
          .collection(AppCollections.notifications)
          .getFullList(filter: 'user_id="$userId"', sort: '-created');
      return records.map((r) => NotificationModel.fromRecord(r)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await pb
          .collection(AppCollections.notifications)
          .update(notificationId, body: {'is_read': true});
    } catch (e) {
      // Ignore error
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final records = await pb
          .collection(AppCollections.notifications)
          .getList(
            filter: 'user_id="$userId" && is_read=false',
            perPage: 1, // Minimize data transfer
          );
      return records.totalItems;
    } catch (e) {
      return 0;
    }
  }
}
