import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceCheckIn extends AttendanceEvent {
  final String scheduleId;
  final String teacherId;
  final double lat;
  final double lng;
  final File file;

  const AttendanceCheckIn({
    required this.scheduleId,
    required this.teacherId,
    required this.lat,
    required this.lng,
    required this.file,
  });

  @override
  List<Object?> get props => [scheduleId, teacherId, lat, lng, file];
}

class AttendanceCheckOut extends AttendanceEvent {
  final String attendanceId;
  final double lat;
  final double lng;

  const AttendanceCheckOut({
    required this.attendanceId,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [attendanceId, lat, lng];
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
