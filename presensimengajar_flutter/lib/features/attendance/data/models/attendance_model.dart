import '../../../schedules/data/models/schedule_model.dart';
import 'package:pocketbase/pocketbase.dart';

class AttendanceModel {
  final String id;
  final String teacherId;
  final String? scheduleId;
  final String date;
  final String type; // office, class
  final String? checkIn;
  final String? checkOut;
  final String status; // hadir, telat, izin, sakit, alpha
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final String? photo;
  final String? notes;
  final ScheduleModel? schedule;

  AttendanceModel({
    required this.id,
    required this.teacherId,
    this.scheduleId,
    required this.date,
    required this.type,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.photo,
    this.notes,
    this.schedule,
  });

  factory AttendanceModel.fromRecord(RecordModel record) {
    ScheduleModel? scheduleData;
    try {
      // expand is Map<String, List<RecordModel>>
      final schedules = record.get<List<RecordModel>>('expand.schedule_id');
      if (schedules.isNotEmpty) {
        scheduleData = ScheduleModel.fromRecord(schedules.first);
      }
    } catch (e) {
      // ignore expansion errors
    }

    return AttendanceModel(
      id: record.id,
      teacherId: record.getStringValue('teacher_id'),
      scheduleId: record.getStringValue('schedule_id').isEmpty
          ? null
          : record.getStringValue('schedule_id'),
      date: record.getStringValue('date'),
      type: record.getStringValue('type'),
      checkIn: record.getStringValue('check_in').isEmpty
          ? null
          : record.getStringValue('check_in'),
      checkOut: record.getStringValue('check_out').isEmpty
          ? null
          : record.getStringValue('check_out'),
      status: record.getStringValue('status'),
      latitude: record.getDoubleValue('latitude') == 0
          ? null
          : record.getDoubleValue('latitude'),
      longitude: record.getDoubleValue('longitude') == 0
          ? null
          : record.getDoubleValue('longitude'),
      locationAddress: record.getStringValue('location_address'),
      photo: record.getStringValue('photo'),
      notes: record.getStringValue('notes'),
      schedule: scheduleData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'schedule_id': scheduleId,
      'date': date,
      'type': type,
      'check_in': checkIn,
      'check_out': checkOut,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'location_address': locationAddress,
      'photo': photo,
      'notes': notes,
    };
  }
}
