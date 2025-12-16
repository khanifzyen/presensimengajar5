import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceCheckIn extends AttendanceEvent {
  final String teacherId;
  final String scheduleId;
  final double latitude;
  final double longitude;
  final File photo;
  final String? notes;

  const AttendanceCheckIn({
    required this.teacherId,
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.photo,
    this.notes,
  });

  @override
  List<Object?> get props => [
    teacherId,
    scheduleId,
    latitude,
    longitude,
    photo,
    notes,
  ];
}

class AttendanceCheckOut extends AttendanceEvent {
  final String attendanceId;
  final double latitude;
  final double longitude;

  const AttendanceCheckOut({
    required this.attendanceId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [attendanceId, latitude, longitude];
}

class AttendanceFetchHistory extends AttendanceEvent {
  final String teacherId;
  final DateTime? startDate;
  final DateTime? endDate;

  const AttendanceFetchHistory({
    required this.teacherId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [teacherId, startDate, endDate];
}

class AttendanceFetchForSchedules extends AttendanceEvent {
  final String teacherId;
  final List<String> scheduleIds;
  final DateTime startDate;
  final DateTime endDate;

  const AttendanceFetchForSchedules({
    required this.teacherId,
    required this.scheduleIds,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [teacherId, scheduleIds, startDate, endDate];
}

class AttendanceFetchWeeklyStatistics extends AttendanceEvent {
  final String teacherId;
  final DateTime weekStart;
  final DateTime weekEnd;

  const AttendanceFetchWeeklyStatistics({
    required this.teacherId,
    required this.weekStart,
    required this.weekEnd,
  });

  @override
  List<Object> get props => [teacherId, weekStart, weekEnd];
}
