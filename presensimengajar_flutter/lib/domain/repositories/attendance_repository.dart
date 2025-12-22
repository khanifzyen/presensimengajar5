import 'dart:io';
import '../../data/models/attendance_model.dart';
import '../../data/models/weekly_statistics_model.dart';

abstract class AttendanceRepository {
  Future<AttendanceModel> checkIn({
    required String teacherId,
    required String scheduleId,
    required double latitude,
    required double longitude,
    required File photo,
    String? notes,
    String? status,
  });

  Future<AttendanceModel> checkOut({
    required String attendanceId,
    required double latitude,
    required double longitude,
  });

  Future<List<AttendanceModel>> getAttendanceHistory(
    String teacherId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Map<String, AttendanceModel>> getAttendanceBySchedules(
    String teacherId,
    List<String> scheduleIds,
    DateTime startDate,
    DateTime endDate,
  );

  Future<WeeklyStatisticsModel> getWeeklyStatistics({
    required String teacherId,
    required DateTime weekStart,
    required DateTime weekEnd,
  });

  Future<List<AttendanceModel>> getOngoingAttendance(String teacherId);
}
