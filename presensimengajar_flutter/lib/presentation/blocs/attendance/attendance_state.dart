import 'package:equatable/equatable.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/weekly_statistics_model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {
  final AttendanceModel attendance;

  const AttendanceSuccess(this.attendance);

  @override
  List<Object> get props => [attendance];
}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<AttendanceModel> history;

  const AttendanceHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class AttendanceScheduleMapLoaded extends AttendanceState {
  final Map<String, AttendanceModel> attendanceMap;

  const AttendanceScheduleMapLoaded(this.attendanceMap);

  @override
  List<Object> get props => [attendanceMap];
}

class AttendanceStatisticsLoaded extends AttendanceState {
  final WeeklyStatisticsModel statistics;

  const AttendanceStatisticsLoaded(this.statistics);

  @override
  List<Object> get props => [statistics];
}

class AttendanceDashboardLoaded extends AttendanceState {
  final WeeklyStatisticsModel statistics;
  final Map<String, AttendanceModel> attendanceMap;

  const AttendanceDashboardLoaded({
    required this.statistics,
    required this.attendanceMap,
  });

  @override
  List<Object> get props => [statistics, attendanceMap];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object> get props => [message];
}
