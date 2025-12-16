import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final PocketBase pb;

  AttendanceRepositoryImpl(this.pb);

  @override
  Future<AttendanceModel> checkIn({
    required String teacherId,
    required String scheduleId,
    required double latitude,
    required double longitude,
    required File photo,
    String? notes,
  }) async {
    final body = {
      'teacher_id': teacherId,
      'schedule_id': scheduleId,
      'date': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD
      'type': 'class', // Default to class for now, logic might change
      'check_in': DateTime.now().toIso8601String(),
      'status': 'hadir', // Default, logic should determine this
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes ?? '',
    };

    final record = await pb
        .collection(AppCollections.attendances)
        .create(
          body: body,
          files: [
            http.MultipartFile.fromBytes(
              'photo',
              await photo.readAsBytes(),
              filename: 'attendance_photo.jpg',
            ),
          ],
        );

    return AttendanceModel.fromRecord(record);
  }

  @override
  Future<AttendanceModel> checkOut({
    required String attendanceId,
    required double latitude,
    required double longitude,
  }) async {
    final body = {
      'check_out': DateTime.now().toIso8601String(),
      // potentially update lat/long out if schema supported it, but it only has one set.
      // Assuming lat/long is for check-in location.
    };

    final record = await pb
        .collection(AppCollections.attendances)
        .update(attendanceId, body: body);

    return AttendanceModel.fromRecord(record);
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory(
    String teacherId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String filter = 'teacher_id="$teacherId"';
    if (startDate != null) {
      filter += ' && date >= "${startDate.toIso8601String()}"';
    }
    if (endDate != null) {
      filter += ' && date <= "${endDate.toIso8601String()}"';
    }

    final records = await pb
        .collection(AppCollections.attendances)
        .getFullList(filter: filter, sort: '-date');

    return records.map((r) => AttendanceModel.fromRecord(r)).toList();
  }

  @override
  Future<Map<String, AttendanceModel>> getAttendanceBySchedules(
    String teacherId,
    List<String> scheduleIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (scheduleIds.isEmpty) {
      return {};
    }

    // Build filter for schedule IDs
    final scheduleFilter = scheduleIds
        .map((id) => 'schedule_id="$id"')
        .join(' || ');

    // Format dates as YYYY-MM-DD for PocketBase date comparison
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];

    final filter =
        'teacher_id="$teacherId" && ($scheduleFilter) && date>="$startDateStr" && date<="$endDateStr"';

    final records = await pb
        .collection(AppCollections.attendances)
        .getFullList(filter: filter);

    // Map by schedule_id for quick lookup
    final Map<String, AttendanceModel> attendanceMap = {};
    for (final record in records) {
      final attendance = AttendanceModel.fromRecord(record);
      if (attendance.scheduleId != null) {
        attendanceMap[attendance.scheduleId!] = attendance;
      }
    }

    return attendanceMap;
  }
}
