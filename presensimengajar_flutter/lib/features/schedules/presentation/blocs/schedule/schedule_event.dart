import 'package:equatable/equatable.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleFetch extends ScheduleEvent {
  final String teacherId;
  final String? day;

  const ScheduleFetch({required this.teacherId, this.day});

  @override
  List<Object?> get props => [teacherId, day];
}
