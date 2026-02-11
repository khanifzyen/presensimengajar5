import 'dart:io';
import '../../data/models/teacher_model.dart';
import '../../../admin/data/models/master_models.dart';

abstract class TeacherRepository {
  Future<TeacherModel?> getTeacherByUserId(String userId);
  Future<List<SubjectModel>> getSubjects();

  Future<List<TeacherModel>> getTeachers({
    String? query,
    String? status, // 'active', 'inactive'
  });

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
  });

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
    String? password, // Optional update password
    File? photo,
  });

  Future<void> deleteTeacher(String teacherId);

  // Existing Profile Update
  Future<TeacherModel> updateTeacher({
    required String teacherId,
    required String name,
    required String phone,
    required String address,
    File? photo,
  });
}
