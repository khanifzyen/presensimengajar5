import 'package:pocketbase/pocketbase.dart';
import 'package:presensimengajar_flutter/core/constants/app_constants.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/domain/repositories/admin_repository.dart';
import 'package:presensimengajar_flutter/features/leave/data/models/leave_request_model.dart';
import 'package:presensimengajar_flutter/features/teachers/data/models/teacher_model.dart';
import 'package:presensimengajar_flutter/features/attendance/data/models/attendance_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final PocketBase pb;

  AdminRepositoryImpl(this.pb);

  @override
  Future<Map<String, int>> getDailyAttendanceStats(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD

      // Get total active teachers
      final totalTeachers = await pb
          .collection(AppCollections.teachers)
          .getFullList(filter: 'status="active"');

      final total = totalTeachers.length;

      // Get attendances for the date
      final attendances = await pb
          .collection(AppCollections.attendances)
          .getFullList(filter: 'date="$dateStr"');

      // Count present (hadir or telat status)
      final present = attendances
          .where(
            (a) =>
                a.getStringValue('status') == 'hadir' ||
                a.getStringValue('status') == 'telat',
          )
          .length;

      // Get approved leave requests for this date
      final leaveRequests = await pb
          .collection(AppCollections.leaveRequests)
          .getFullList(
            filter:
                'status="approved" && start_date<="$dateStr" && end_date>="$dateStr"',
          );

      final leave = leaveRequests.length;

      // Calculate absent (total - present - leave)
      final absent = total - present - leave;

      return {
        'total': total,
        'present': present,
        'leave': leave,
        'absent': absent > 0 ? absent : 0, // Ensure non-negative
      };
    } catch (e) {
      // Return zeros on error
      return {'total': 0, 'present': 0, 'leave': 0, 'absent': 0};
    }
  }

  @override
  Future<Map<String, int>> getTeacherCategoryStats() async {
    try {
      final teachers = await pb
          .collection(AppCollections.teachers)
          .getFullList(filter: 'status="active"');

      int tetap = 0;
      int jadwal = 0;
      int presensiKantor = 0;
      int presensiMengajar = 0;

      for (final teacher in teachers) {
        final category = teacher.getStringValue('attendance_category');

        // Count by attendance category
        if (category == 'tetap') {
          tetap++;
          presensiKantor++; // Guru tetap = presensi kantor
        } else if (category == 'jadwal') {
          jadwal++;
          presensiMengajar++; // Guru jadwal = presensi mengajar
        }
      }

      return {
        'tetap': tetap,
        'jadwal': jadwal,
        'presensi_kantor': presensiKantor,
        'presensi_mengajar': presensiMengajar,
      };
    } catch (e) {
      return {
        'tetap': 0,
        'jadwal': 0,
        'presensi_kantor': 0,
        'presensi_mengajar': 0,
      };
    }
  }

  @override
  Future<List<LeaveRequestModel>> getPendingLeaveRequests() async {
    try {
      final records = await pb
          .collection(AppCollections.leaveRequests)
          .getFullList(
            filter: 'status="pending"',
            sort: '-created',
            expand: 'teacher_id',
          );

      return records.map((r) => LeaveRequestModel.fromRecord(r)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRealtimeMonitoring(
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      // Get all active teachers
      final teacherRecords = await pb
          .collection(AppCollections.teachers)
          .getFullList(filter: 'status="active"', sort: 'name');

      final teachers = teacherRecords
          .map((r) => TeacherModel.fromRecord(r))
          .toList();

      // Get attendances for this date
      final attendanceRecords = await pb
          .collection(AppCollections.attendances)
          .getFullList(
            filter: 'date="$dateStr"',
            expand: 'schedule_id,schedule_id.subject_id,schedule_id.class_id',
          );

      final attendances = attendanceRecords
          .map((r) => AttendanceModel.fromRecord(r))
          .toList();

      // Get leave requests for this date
      final leaveRecords = await pb
          .collection(AppCollections.leaveRequests)
          .getFullList(
            filter:
                'status="approved" && start_date<="$dateStr" && end_date>="$dateStr"',
          );

      final leaves = leaveRecords
          .map((r) => LeaveRequestModel.fromRecord(r))
          .toList();

      // Build monitoring data
      final List<Map<String, dynamic>> monitoring = [];

      for (final teacher in teachers) {
        // Find attendance for this teacher
        final attendance = attendances.firstWhere(
          (a) => a.teacherId == teacher.id,
          orElse: () => AttendanceModel(
            id: '',
            teacherId: teacher.id,
            date: dateStr,
            type: teacher.attendanceCategory == 'tetap' ? 'office' : 'class',
            status: 'alpha',
          ),
        );

        // Find leave request for this teacher
        final leave = leaves.firstWhere(
          (l) => l.teacherId == teacher.id,
          orElse: () => LeaveRequestModel(
            id: '',
            teacherId: teacher.id,
            type: '',
            startDate: '',
            endDate: '',
            reason: '',
            status: '',
          ),
        );

        // Determine status
        String status = attendance.status;
        String statusText = '';
        String statusColor = '';

        if (leave.status == 'approved') {
          status = leave.type; // sakit, cuti, dinas
          statusText = leave.type == 'sakit'
              ? 'Sakit'
              : leave.type == 'cuti'
              ? 'Cuti'
              : 'Dinas';
          statusColor = 'permit';
        } else if (attendance.checkIn != null) {
          if (status == 'hadir') {
            statusText = 'Hadir ${_formatTime(attendance.checkIn!)}';
            statusColor = 'present';
          } else if (status == 'telat') {
            // Calculate late minutes
            statusText = 'Telat 10m'; // Simplified, can calculate actual
            statusColor = 'late';
          }
        } else {
          statusText = 'Alpha';
          statusColor = 'absent';
        }

        // Get subject and class info from expanded data
        String subjectInfo = teacher.attendanceCategory == 'tetap'
            ? 'Presensi Kantor'
            : 'Presensi Mengajar';

        // Try to get schedule info from attendance record
        if (attendance.scheduleId != null && attendanceRecords.isNotEmpty) {
          try {
            final attendanceRecord = attendanceRecords.firstWhere(
              (r) => r.id == attendance.id,
              orElse: () => attendanceRecords.first,
            );

            // Access expand data from the record's data map
            final expandData =
                attendanceRecord.data['expand'] as Map<String, dynamic>?;
            if (expandData != null && expandData.containsKey('schedule_id')) {
              final scheduleData =
                  expandData['schedule_id'] as Map<String, dynamic>?;
              if (scheduleData != null) {
                final scheduleExpand =
                    scheduleData['expand'] as Map<String, dynamic>?;
                if (scheduleExpand != null &&
                    scheduleExpand.containsKey('subject_id') &&
                    scheduleExpand.containsKey('class_id')) {
                  final subjectData =
                      scheduleExpand['subject_id'] as Map<String, dynamic>?;
                  final classDataMap =
                      scheduleExpand['class_id'] as Map<String, dynamic>?;
                  if (subjectData != null && classDataMap != null) {
                    final subjectName = subjectData['name'] as String? ?? '';
                    final className = classDataMap['name'] as String? ?? '';
                    if (subjectName.isNotEmpty && className.isNotEmpty) {
                      subjectInfo = '$subjectName ($className)';
                    }
                  }
                }
              }
            }
          } catch (e) {
            // Keep default subjectInfo if expand parsing fails
          }
        }

        monitoring.add({
          'teacher': teacher,
          'status': status,
          'statusText': statusText,
          'statusColor': statusColor,
          'subjectInfo': subjectInfo,
          'category': teacher.attendanceCategory,
          'categoryBadge': teacher.attendanceCategory == 'tetap'
              ? 'Tetap'
              : 'Jadwal',
        });
      }

      return monitoring;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyAttendanceReport(
    int month,
    int year, {
    String? teacherId,
    String? category,
  }) async {
    try {
      // 1. Get all active teachers
      final teachers = await pb
          .collection(AppCollections.teachers)
          .getFullList(filter: 'status="active"', sort: 'name');

      // 2. Construct date range for the month
      final startDate = DateTime(
        year,
        month,
        1,
      ).toIso8601String().split('T')[0];
      // Get last day of month
      final lastDay = (month < 12)
          ? DateTime(year, month + 1, 0)
          : DateTime(year + 1, 1, 0);
      final endDate = lastDay.toIso8601String().split('T')[0];

      // 3. Get all attendances for the month
      final attendances = await pb
          .collection(AppCollections.attendances)
          .getFullList(filter: 'date>="$startDate" && date<="$endDate"');

      // 4. Aggregate data per teacher
      final List<Map<String, dynamic>> report = [];

      // Filter teachers if needed
      var filteredTeachers = teachers;
      if (category != null && category.isNotEmpty) {
        filteredTeachers = filteredTeachers
            .where((t) => t.getStringValue('attendance_category') == category)
            .toList();
      }

      if (teacherId != null && teacherId.isNotEmpty) {
        filteredTeachers = filteredTeachers
            .where((t) => t.id == teacherId)
            .toList();
      }

      for (final teacherRecord in filteredTeachers) {
        final tId = teacherRecord.id;
        final tName = teacherRecord.getStringValue('name');
        final tNip = teacherRecord.getStringValue('nip');

        // Filter attendances for this teacher
        final teacherAttendances = attendances
            .where((a) => a.getStringValue('teacher_id') == tId)
            .toList();

        int present = 0;
        int late = 0;
        int permit = 0;
        int alpha = 0;

        for (final att in teacherAttendances) {
          final status = att.getStringValue('status');
          final type = att.getStringValue('type');

          if (type == 'leave') {
            permit++;
          } else if (status == 'hadir') {
            present++;
          } else if (status == 'telat') {
            late++;
          } else if (status == 'alpha') {
            alpha++;
          }
        }

        report.add({
          'teacherId': tId,
          'teacherName': tName,
          'teacherNip': tNip,
          'present': present,
          'late': late,
          'permit': permit,
          'alpha': alpha,
          'totalAttendance': present + late + permit + alpha,
        });
      }

      return report;
    } catch (e) {
      return [];
    }
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
