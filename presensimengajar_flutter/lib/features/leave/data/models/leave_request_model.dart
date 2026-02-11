import 'package:pocketbase/pocketbase.dart';

class LeaveRequestModel {
  final String id;
  final String teacherId;
  final String type; // sakit, cuti, dinas
  final String startDate;
  final String endDate;
  final String reason;
  final String? attachment;
  final String status; // pending, approved, rejected
  final String? approvedBy;
  final String? approvedAt;
  final String? rejectionReason;
  final String? teacherName;
  final String? teacherPhoto;

  LeaveRequestModel({
    required this.id,
    required this.teacherId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.attachment,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.teacherName,
    this.teacherPhoto,
  });

  factory LeaveRequestModel.fromRecord(RecordModel record) {
    String? name;
    String? photo;

    // Check expansion
    if (record.expand.containsKey('teacher_id')) {
      final teacherRecords = record.expand['teacher_id'];
      if (teacherRecords != null && teacherRecords.isNotEmpty) {
        final teacher = teacherRecords.first;
        name = teacher.getStringValue('name');
        photo = teacher.getStringValue('photo');
      }
    }

    return LeaveRequestModel(
      id: record.id,
      teacherId: record.getStringValue('teacher_id'),
      type: record.getStringValue('type'),
      startDate: record.getStringValue('start_date'),
      endDate: record.getStringValue('end_date'),
      reason: record.getStringValue('reason'),
      attachment: record.getStringValue('attachment'),
      status: record.getStringValue('status'),
      approvedBy: record.getStringValue('approved_by'),
      approvedAt: record.getStringValue('approved_at'),
      rejectionReason: record.getStringValue('rejection_reason'),
      teacherName: name,
      teacherPhoto: photo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'attachment': attachment,
      'status': status,
    };
  }
}
