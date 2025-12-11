import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  // Add NotificationRepository dependency when created
  // final NotificationRepository notificationRepository;

  NotificationBloc() : super(NotificationInitial()) {
    on<NotificationFetch>(_onNotificationFetch);
  }

  Future<void> _onNotificationFetch(
    NotificationFetch event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      // TODO: Implement actual fetch logic
      // final notifications = await notificationRepository.getNotifications(event.userId);
      // emit(NotificationLoaded(notifications));
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
      emit(const NotificationLoaded([])); // Mock empty list
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
