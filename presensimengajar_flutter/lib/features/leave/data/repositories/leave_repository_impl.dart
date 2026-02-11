import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/leave_repository.dart';
import '../models/leave_request_model.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final PocketBase pb;

  LeaveRepositoryImpl(this.pb);

  @override
  Future<LeaveRequestModel> requestLeave({
    required String teacherId,
    required String type,
    required String startDate,
    required String endDate,
    required String reason,
    File? attachment,
  }) async {
    final body = {
      'teacher_id': teacherId,
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'status': 'pending',
    };

    List<http.MultipartFile> files = [];
    if (attachment != null) {
      final filename = attachment.path.split(Platform.pathSeparator).last;
      files.add(
        http.MultipartFile.fromBytes(
          'attachment',
          await attachment.readAsBytes(),
          filename: filename,
        ),
      );
    }

    final record = await pb
        .collection(AppCollections.leaveRequests)
        .create(body: body, files: files);

    return LeaveRequestModel.fromRecord(record);
  }

  @override
  Future<List<LeaveRequestModel>> getLeaveHistory(String teacherId) async {
    final records = await pb
        .collection(AppCollections.leaveRequests)
        .getFullList(filter: 'teacher_id="$teacherId"', sort: '-start_date');

    return records.map((r) => LeaveRequestModel.fromRecord(r)).toList();
  }

  @override
  Future<List<LeaveRequestModel>> getAllLeaves({
    String? status,
    String? query,
  }) async {
    String filter = '';

    // Status Filter
    if (status != null && status != 'all') {
      filter = 'status="$status"';
    }

    // Since PocketBase search on relation fields (like teacher_id.name) needs index or specific flow,
    // and "query" is usually just done via local filtering in Bloc for simplicity if list is small.
    // But if we want server side, we can try to filter by 'type'.
    // Filtering by teacher name (relation) is harder in simple filter string without 'expand' access in loose validation.
    // We will just fetch list sorted by date and let Bloc/UI handle complex text search on the "expanded" teacher name.

    final records = await pb
        .collection(AppCollections.leaveRequests)
        .getFullList(
          filter: filter.isNotEmpty ? filter : null,
          sort: '-created',
          expand: 'teacher_id', // Expand to get teacher details
        );

    return records.map((r) => LeaveRequestModel.fromRecord(r)).toList();
  }

  @override
  Future<void> approveLeave(String leaveId, String adminId) async {
    // 1. Update Leave Status
    final now = DateTime.now().toUtc().toIso8601String();
    await pb
        .collection(AppCollections.leaveRequests)
        .update(
          leaveId,
          body: {
            'status': 'approved',
            'approved_by':
                adminId, // Assuming admin is just Current User or we store Admin Name?
            // AdminId usually refers to User ID.
            'approved_at': now,
          },
        );

    // 2. Generate Attendance Records
    // Need to fetch details of the leave first
    final leaveRecord = await pb
        .collection(AppCollections.leaveRequests)
        .getOne(leaveId);
    final leave = LeaveRequestModel.fromRecord(leaveRecord);

    final teacherId = leave.teacherId;
    final startDate = DateTime.parse(leave.startDate);
    final endDate = DateTime.parse(leave.endDate);

    // Fetch Teacher's Schedules
    final schedules = await pb
        .collection(AppCollections.schedules)
        .getFullList(filter: 'teacher_id="$teacherId"');

    // Day Mapping (Indonesian to DateTime.weekday)
    final dayMap = {
      'senin': 1,
      'selasa': 2,
      'rabu': 3,
      'kamis': 4,
      'jumat': 5,
      'sabtu': 6,
      'minggu': 7,
    };

    // Iterate through dates
    // Loop from start to end (inclusive)
    for (
      var date = startDate;
      date.isBefore(endDate.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      final weekday = date.weekday;

      // Find matching schedules
      for (var schedule in schedules) {
        final scheduleDay = schedule.getStringValue('day').toLowerCase();
        if (dayMap[scheduleDay] == weekday) {
          // Check if attendance already exists? Maybe safer to check.
          // But create will fail if unique constraint violated? PocketBase usually doesn't have unique on teacher+schedule+date unless configured.
          // We will attempt create.

          try {
            await pb
                .collection(AppCollections.attendances)
                .create(
                  body: {
                    'teacher_id': teacherId,
                    'schedule_id': schedule.id,
                    'date': date.toIso8601String().split('T')[0],
                    'status': leave.type, // 'sakit' / 'izin' / 'cuti'
                    'type': 'leave', // Mark as leave auto-generated
                    'notes': 'Izin disetujui: ${leave.reason}',
                    // 'check_in': null, // Empty for leave
                    // 'check_out': null
                  },
                );
          } catch (e) {
            print(
              "Skipping duplicate or error attendance for ${schedule.id}: $e",
            );
          }
        }
      }
    }
  }

  @override
  Future<void> rejectLeave(
    String leaveId,
    String reason,
    String adminId,
  ) async {
    await pb
        .collection(AppCollections.leaveRequests)
        .update(
          leaveId,
          body: {
            'status': 'rejected',
            'rejection_reason': reason,
            'approved_by': adminId, // Reuse field for who rejected
            'approved_at': DateTime.now().toUtc().toIso8601String(),
          },
        );
  }
}
