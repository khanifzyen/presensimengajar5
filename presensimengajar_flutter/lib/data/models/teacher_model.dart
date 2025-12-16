import 'package:pocketbase/pocketbase.dart';

class TeacherModel {
  final String id;
  final String userId;
  final String nip;
  final String name;
  final String phone;
  final String address;
  final String photo;
  final String? subjectId;
  final String position; // 'guru', 'kepala_sekolah', etc.
  final String attendanceCategory; // 'tetap', 'jadwal'
  final String status; // 'active', 'inactive'
  final String joinDate;

  TeacherModel({
    required this.id,
    required this.userId,
    required this.nip,
    required this.name,
    required this.phone,
    required this.address,
    required this.photo,
    this.subjectId,
    required this.position,
    required this.attendanceCategory,
    required this.status,
    required this.joinDate,
  });

  factory TeacherModel.fromRecord(RecordModel record) {
    return TeacherModel(
      id: record.id,
      userId: record.getStringValue('user_id'),
      nip: record.getStringValue('nip'),
      name: record.getStringValue('name'),
      phone: record.getStringValue('phone'),
      address: record.getStringValue('address'),
      photo: record.getStringValue('photo'),
      subjectId: record.getStringValue('subject_id').isEmpty
          ? null
          : record.getStringValue('subject_id'),
      position: record.getStringValue('position'),
      attendanceCategory: record.getStringValue('attendance_category'),
      status: record.getStringValue('status'),
      joinDate: record.getStringValue('join_date'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nip': nip,
      'name': name,
      'phone': phone,
      'address': address,
      'photo': photo,
      'subject_id': subjectId,
      'position': position,
      'attendance_category': attendanceCategory,
      'status': status,
      'join_date': joinDate,
    };
  }

  /// Get full photo URL from PocketBase
  /// Format: {baseUrl}/api/files/{collectionName}/{recordId}/{filename}
  String getPhotoUrl(String baseUrl) {
    if (photo.isEmpty) return '';
    // If already a full URL, return as is
    if (photo.startsWith('http')) return photo;
    // Construct full URL
    return '$baseUrl/api/files/teachers/$id/$photo';
  }
}
