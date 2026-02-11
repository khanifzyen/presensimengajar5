import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../../admin/data/models/master_models.dart';
import '../models/teacher_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final PocketBase pb;

  TeacherRepositoryImpl(this.pb);

  @override
  Future<TeacherModel?> getTeacherByUserId(String userId) async {
    try {
      final record = await pb
          .collection(AppCollections.teachers)
          .getFirstListItem('user_id="$userId"');
      return TeacherModel.fromRecord(record);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TeacherModel>> getTeachers({
    String? query,
    String? status,
  }) async {
    String filter = '';
    final List<String> conditions = [];

    if (query != null && query.isNotEmpty) {
      // Search by name or NIP
      conditions.add('(name ~ "$query" || nip ~ "$query")');
    }

    if (status != null && status != 'all') {
      conditions.add('status = "$status"');
    }

    if (conditions.isNotEmpty) {
      filter = conditions.join(' && ');
    }

    final records = await pb
        .collection(AppCollections.teachers)
        .getFullList(filter: filter, sort: 'name', expand: 'subject_id');

    return records.map((r) => TeacherModel.fromRecord(r)).toList();
  }

  @override
  Future<TeacherModel> createTeacher({
    required String email,
    required String password,
    required String nip,
    required String name,
    required String position,
    required String phone,
    required String address,
    required String attendanceCategory,
    required String status,
    required String joinDate,
    String? subjectId,
    File? photo,
  }) async {
    // 1. Create User
    final userBody = {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'name': name,
      'role': 'teacher',
    };

    final userRecord = await pb
        .collection(AppCollections.users)
        .create(body: userBody);

    // 2. Create Teacher
    final teacherBody = {
      'user_id': userRecord.id,
      'nip': nip,
      'name': name,
      'phone': phone,
      'address': address,
      'attendance_category': attendanceCategory,
      'status': status,
      'join_date': joinDate,
      'position': position,
      if (subjectId != null) 'subject_id': subjectId,
    };

    final record = await pb
        .collection(AppCollections.teachers)
        .create(
          body: teacherBody,
          files: photo != null
              ? [
                  http.MultipartFile.fromBytes(
                    'photo',
                    await photo.readAsBytes(),
                    filename: 'profile.jpg',
                  ),
                ]
              : [],
        );

    return TeacherModel.fromRecord(record);
  }

  @override
  Future<TeacherModel> updateTeacherAdmin({
    required String teacherId,
    required String nip,
    required String name,
    required String position,
    required String phone,
    required String address,
    required String attendanceCategory,
    required String status,
    required String joinDate,
    String? subjectId,
    String? password,
    File? photo,
  }) async {
    // 1. Update Teacher Data
    final teacherBody = {
      'nip': nip,
      'name': name,
      'phone': phone,
      'address': address,
      'attendance_category': attendanceCategory,
      'status': status,
      'join_date': joinDate,
      if (subjectId != null) 'subject_id': subjectId,
    };

    final record = await pb
        .collection(AppCollections.teachers)
        .update(
          teacherId,
          body: teacherBody,
          files: photo != null
              ? [
                  http.MultipartFile.fromBytes(
                    'photo',
                    await photo.readAsBytes(),
                    filename: 'profile.jpg',
                  ),
                ]
              : [],
        );

    // 2. Update User (Password) if provided
    if (password != null && password.isNotEmpty) {
      final userId = record.getStringValue('user_id');
      if (userId.isNotEmpty) {
        await pb
            .collection(AppCollections.users)
            .update(
              userId,
              body: {
                'password': password,
                'passwordConfirm': password,
                'name': name, // Update name in user too
              },
            );
      }
    } else {
      // Sync name in user
      final userId = record.getStringValue('user_id');
      if (userId.isNotEmpty) {
        await pb
            .collection(AppCollections.users)
            .update(userId, body: {'name': name});
      }
    }

    return TeacherModel.fromRecord(record);
  }

  @override
  Future<void> deleteTeacher(String teacherId) async {
    // Get teacher to find user_id
    final teacher = await pb
        .collection(AppCollections.teachers)
        .getOne(teacherId);
    final userId = teacher.getStringValue('user_id');

    // Delete teacher first
    await pb.collection(AppCollections.teachers).delete(teacherId);

    // Delete user if exists
    if (userId.isNotEmpty) {
      try {
        await pb.collection(AppCollections.users).delete(userId);
      } catch (e) {
        // Ignore if user deletion fails (maybe already deleted)
      }
    }
  }

  @override
  Future<TeacherModel> updateTeacher({
    required String teacherId,
    required String name,
    required String phone,
    required String address,
    File? photo,
  }) async {
    final body = {'name': name, 'phone': phone, 'address': address};

    final record = await pb
        .collection(AppCollections.teachers)
        .update(
          teacherId,
          body: body,
          files: photo != null
              ? [
                  http.MultipartFile.fromBytes(
                    'photo',
                    await photo.readAsBytes(),
                    filename: 'profile_photo.jpg',
                  ),
                ]
              : [],
        );
    return TeacherModel.fromRecord(record);
  }

  @override
  Future<List<SubjectModel>> getSubjects() async {
    final records = await pb
        .collection(AppCollections.subjects)
        .getFullList(sort: 'name');
    return records.map((r) => SubjectModel.fromRecord(r)).toList();
  }
}
