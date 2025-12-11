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

  // Expand relations if needed
  final RecordModel? subject;
  final RecordModel? classInfo;

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
    this.subject,
    this.classInfo,
  });

  factory ScheduleModel.fromRecord(RecordModel record) {
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
      subject: record
          .get<List<RecordModel>>('expand.subject_id', [])
          .firstOrNull,
      classInfo: record
          .get<List<RecordModel>>('expand.class_id', [])
          .firstOrNull,
    );
  }
}
