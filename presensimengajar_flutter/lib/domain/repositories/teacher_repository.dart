import '../../data/models/teacher_model.dart';

abstract class TeacherRepository {
  Future<TeacherModel?> getTeacherByUserId(String userId);
  Future<TeacherModel> updateTeacher(TeacherModel teacher);
}
