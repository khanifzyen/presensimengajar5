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
}
