import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';
import '../models/weekly_statistics_model.dart';
import '../models/schedule_model.dart';
import '../models/leave_request_model.dart';

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

  @override
  Future<WeeklyStatisticsModel> getWeeklyStatistics({
    required String teacherId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    try {
      // Step 1: Get all schedules for this teacher
      final scheduleRecords = await pb
          .collection(AppCollections.schedules)
          .getFullList(
            filter: 'teacher_id="$teacherId"',
            expand: 'subject_id,class_id',
          );

      if (scheduleRecords.isEmpty) {
        return WeeklyStatisticsModel.empty();
      }

      final schedules = scheduleRecords
          .map((r) => ScheduleModel.fromRecord(r))
          .toList();

      // Step 2: Calculate which days fall within this week
      final weekDays = <String>[];
      final dayNames = [
        'senin',
        'selasa',
        'rabu',
        'kamis',
        'jumat',
        'sabtu',
        'minggu',
      ];

      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        if (date.weekday >= 1 && date.weekday <= 7) {
          weekDays.add(dayNames[date.weekday - 1]);
        }
      }

      // Step 3: Count total scheduled classes for this week
      final totalScheduled = schedules
          .where((s) => weekDays.contains(s.day.toLowerCase()))
          .length;

      // Step 4: Get all attendances for this week
      final startDateStr = weekStart.toIso8601String().split('T')[0];
      final endDateStr = weekEnd.toIso8601String().split('T')[0];

      final attendanceRecords = await pb
          .collection(AppCollections.attendances)
          .getFullList(
            filter:
                'teacher_id="$teacherId" && date>="$startDateStr" && date<="$endDateStr"',
          );

      final attendances = attendanceRecords
          .map((r) => AttendanceModel.fromRecord(r))
          .toList();

      // Step 5: Count classes attended (with check-in)
      final classesAttended = attendances
          .where((a) => a.checkIn != null)
          .length;

      // Step 6: Count late arrivals (check-in > start time + 15 minutes)
      int lateArrivals = 0;
      final gracePeriodMinutes = 15;

      for (final attendance in attendances) {
        if (attendance.checkIn == null || attendance.scheduleId == null) {
          continue;
        }

        // Parse checkIn string to DateTime
        final checkInTime = DateTime.tryParse(attendance.checkIn!);
        if (checkInTime == null) continue;

        // Find corresponding schedule
        final schedule = schedules.firstWhere(
          (s) => s.id == attendance.scheduleId,
          orElse: () => schedules.first, // Fallback, shouldn't happen
        );

        // Parse schedule start time (format: "HH:mm")
        final timeParts = schedule.startTime.split(':');
        if (timeParts.length != 2) continue;

        final scheduledHour = int.tryParse(timeParts[0]) ?? 0;
        final scheduledMinute = int.tryParse(timeParts[1]) ?? 0;

        // Create scheduled start time on the attendance date
        final scheduledStart = DateTime(
          checkInTime.year,
          checkInTime.month,
          checkInTime.day,
          scheduledHour,
          scheduledMinute,
        );

        // Add grace period
        final graceDeadline = scheduledStart.add(
          Duration(minutes: gracePeriodMinutes),
        );

        // Check if late
        if (checkInTime.isAfter(graceDeadline)) {
          lateArrivals++;
        }
      }

      // Step 7: Get approved leave requests for this week
      final leaveRecords = await pb
          .collection(AppCollections.leaveRequests)
          .getFullList(
            filter:
                'teacher_id="$teacherId" && status="approved" && '
                '((start_date>="$startDateStr" && start_date<="$endDateStr") || '
                '(end_date>="$startDateStr" && end_date<="$endDateStr") || '
                '(start_date<="$startDateStr" && end_date>="$endDateStr"))',
          );

      // Count affected days by leave requests
      int leaveAffectedClasses = 0;
      for (final leaveRecord in leaveRecords) {
        final leave = LeaveRequestModel.fromRecord(leaveRecord);

        // Parse dates
        final leaveStart = DateTime.tryParse(leave.startDate);
        final leaveEnd = DateTime.tryParse(leave.endDate);

        if (leaveStart == null || leaveEnd == null) continue;

        // Count how many scheduled classes fall within leave period
        for (final schedule in schedules) {
          if (!weekDays.contains(schedule.day.toLowerCase())) continue;

          // Check each day of the week
          for (int i = 0; i < 7; i++) {
            final date = weekStart.add(Duration(days: i));
            final dayName = dayNames[date.weekday - 1];

            if (dayName == schedule.day.toLowerCase() &&
                !date.isBefore(leaveStart) &&
                !date.isAfter(leaveEnd)) {
              leaveAffectedClasses++;
            }
          }
        }
      }

      return WeeklyStatisticsModel(
        totalScheduled: totalScheduled,
        classesAttended: classesAttended,
        lateArrivals: lateArrivals,
        leaveRequests: leaveAffectedClasses,
      );
    } catch (e) {
      // Return empty statistics on error
      return WeeklyStatisticsModel.empty();
    }
  }
}
