import 'package:pocketbase/pocketbase.dart';

class AcademicPeriodModel {
  final String id;
  final String name;
  final String semester;
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'semester': semester,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
    };
  }

  DateTime get startDateTime => DateTime.parse(startDate);
  DateTime get endDateTime => DateTime.parse(endDate);
}
