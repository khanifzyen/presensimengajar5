import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceFetchSettings extends AttendanceEvent {}

class AttendanceCheckIn extends AttendanceEvent {
  final String scheduleId;
  final String teacherId;
  final double lat;
  final double lng;
  final File file;
  final String scheduleStartTime;
  final String scheduleEndTime;

  const AttendanceCheckIn({
    required this.scheduleId,
    required this.teacherId,
    required this.lat,
    required this.lng,
    required this.file,
    required this.scheduleStartTime,
    required this.scheduleEndTime,
  });

  @override
  List<Object?> get props => [
    scheduleId,
    teacherId,
    lat,
    lng,
    file,
    scheduleStartTime,
    scheduleEndTime,
  ];
}

class AttendanceCheckOut extends AttendanceEvent {
  final String attendanceId;
  final double lat;
  final double lng;
  final DateTime checkInTime;

  const AttendanceCheckOut({
    required this.attendanceId,
    required this.lat,
    required this.lng,
    required this.checkInTime,
  });

  @override
  List<Object?> get props => [attendanceId, lat, lng, checkInTime];
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

class AttendanceFetchDashboardData extends AttendanceEvent {
  final String teacherId;
  final List<String> scheduleIds;
  final DateTime weekStart;
  final DateTime weekEnd;

  const AttendanceFetchDashboardData({
    required this.teacherId,
    required this.scheduleIds,
    required this.weekStart,
    required this.weekEnd,
  });

  @override
  List<Object> get props => [teacherId, scheduleIds, weekStart, weekEnd];
}
