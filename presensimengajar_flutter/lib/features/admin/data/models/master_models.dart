import 'package:pocketbase/pocketbase.dart';

class SubjectModel {
  final String id;
  final String name;
  final String code;
  final String description;

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  factory SubjectModel.fromRecord(RecordModel record) {
    return SubjectModel(
      id: record.id,
      name: record.getStringValue('name'),
      code: record.getStringValue('code'),
      description: record.getStringValue('description'),
    );
  }
}

class ClassModel {
  final String id;
  final String name;
  final String level; // X, XI, XII
  final String major; // IPA, IPS, Umum
  final String room;
  final int capacity;

  ClassModel({
    required this.id,
    required this.name,
    required this.level,
    required this.major,
    required this.room,
    required this.capacity,
  });

  factory ClassModel.fromRecord(RecordModel record) {
    return ClassModel(
      id: record.id,
      name: record.getStringValue('name'),
      level: record.getStringValue('level'),
      major: record.getStringValue('major'),
      room: record.getStringValue('room'),
      capacity: record.getIntValue('capacity'),
    );
  }
}

class AcademicPeriodModel {
  final String id;
  final String name;
  final String semester; // ganjil, genap
  final String startDate;
  final String endDate;
  final bool isActive;

  AcademicPeriodModel({
    required this.id,
    required this.name,
    required this.semester,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory AcademicPeriodModel.fromRecord(RecordModel record) {
    return AcademicPeriodModel(
      id: record.id,
      name: record.getStringValue('name'),
      semester: record.getStringValue('semester'),
      startDate: record.getStringValue('start_date'),
      endDate: record.getStringValue('end_date'),
      isActive: record.getBoolValue('is_active'),
    );
  }
}
