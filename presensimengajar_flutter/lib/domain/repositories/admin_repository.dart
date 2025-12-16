import '../../../data/models/leave_request_model.dart';

abstract class AdminRepository {
  /// Get daily attendance statistics for a specific date
  /// Returns a map with keys: total, present, leave, absent
  Future<Map<String, int>> getDailyAttendanceStats(DateTime date);

  /// Get teacher category statistics
  /// Returns a map with keys: tetap, jadwal, presensi_kantor, presensi_mengajar
  Future<Map<String, int>> getTeacherCategoryStats();

  /// Get pending leave requests
  Future<List<LeaveRequestModel>> getPendingLeaveRequests();

  /// Get real-time monitoring data for teachers on a specific date
  /// Returns list of maps containing teacher info, attendance status, etc.
  Future<List<Map<String, dynamic>>> getRealtimeMonitoring(DateTime date);
}
