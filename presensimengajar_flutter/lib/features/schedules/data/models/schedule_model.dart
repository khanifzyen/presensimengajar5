import 'package:pocketbase/pocketbase.dart';

class ScheduleModel {
  final String id;
  final String teacherId;
  final String subjectId;
  final String classId;
  final String periodId;
  final String day; // senin, selasa, ...
  final String startTime;
  final String endTime;
  final String room;
  final String type; // regular, replacement, additional
  final String? specificDate; // YYYY-MM-DD

  // Expand relations if needed
  final RecordModel? subject;
  final RecordModel? classInfo;
  final Map<String, dynamic>? expand;

  ScheduleModel({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.classId,
    required this.periodId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.type = 'regular',
    this.specificDate,
    this.subject,
    this.classInfo,
    this.expand,
  });

  factory ScheduleModel.fromRecord(RecordModel record) {
    // Extract expand data
    Map<String, dynamic>? expandData;
    try {
      final expandRaw = record.data['expand'];
      if (expandRaw != null && expandRaw is Map) {
        expandData = Map<String, dynamic>.from(expandRaw);
      }
    } catch (e) {
      expandData = null;
    }

    return ScheduleModel(
      id: record.id,
      teacherId: record.getStringValue('teacher_id'),
      subjectId: record.getStringValue('subject_id'),
      classId: record.getStringValue('class_id'),
      periodId: record.getStringValue('period_id'),
      day: record.getStringValue('day'),
      startTime: record.getStringValue('start_time'),
      endTime: record.getStringValue('end_time'),
      room: record.getStringValue('room'),
      type: record.getStringValue('type').isEmpty
          ? 'regular'
          : record.getStringValue('type'),
      specificDate: record.getStringValue('specific_date').isEmpty
          ? null
          : record.getStringValue('specific_date'),
      subject: record.get<List<RecordModel>>('expand.subject_id', []).firstOrNull,
      classInfo: record
          .get<List<RecordModel>>('expand.class_id', [])
          .firstOrNull,
      expand: expandData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'subject_id': subjectId,
      'class_id': classId,
      'period_id': periodId,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'type': type,
      'specific_date': specificDate,
    };
  }
}
