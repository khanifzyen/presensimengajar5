import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class LeaveRequestSubmit extends LeaveEvent {
  final String teacherId;
  final String type;
  final String startDate;
  final String endDate;
  final String reason;
  final File? attachment;

  const LeaveRequestSubmit({
    required this.teacherId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.attachment,
  });

  @override
  List<Object?> get props => [
    teacherId,
    type,
    startDate,
    endDate,
    reason,
    attachment,
  ];
}

class LeaveFetchHistory extends LeaveEvent {
  final String teacherId;

  const LeaveFetchHistory(this.teacherId);

  @override
  List<Object> get props => [teacherId];
}
