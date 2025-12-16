import 'dart:io';
import '../../data/models/teacher_model.dart';

abstract class TeacherRepository {
  Future<TeacherModel?> getTeacherByUserId(String userId);
  Future<TeacherModel> updateTeacher({
    required String teacherId,
    required String name,
    required String phone,
    required String address,
    File? photo,
  });
}
