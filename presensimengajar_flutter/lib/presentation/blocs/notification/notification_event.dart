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
