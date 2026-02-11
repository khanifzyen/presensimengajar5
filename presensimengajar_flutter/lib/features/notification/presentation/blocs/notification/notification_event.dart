import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class NotificationFetch extends NotificationEvent {
  final String userId;

  const NotificationFetch(this.userId);

  @override
  List<Object> get props => [userId];
}

class NotificationMarkRead extends NotificationEvent {
  final String userId;
  final String notificationId;

  const NotificationMarkRead(this.userId, this.notificationId);

  @override
  List<Object> get props => [userId, notificationId];
}
