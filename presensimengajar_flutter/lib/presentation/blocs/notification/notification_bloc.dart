import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository}) : super(NotificationInitial()) {
    on<NotificationFetch>(_onNotificationFetch);
    on<NotificationMarkRead>(_onNotificationMarkRead);
  }

  Future<void> _onNotificationFetch(
    NotificationFetch event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await notificationRepository.getNotifications(event.userId);
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onNotificationMarkRead(
    NotificationMarkRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationRepository.markAsRead(event.notificationId);
      // We could re-fetch or optimistically update. 
      // For simplicity, let's just trigger a re-fetch if needed or assume UI handles it locally?
      // Better to re-fetch to ensure consistency.
      add(NotificationFetch(event.userId));
    } catch (e) {
      // Ignore error
    }
  }
}
