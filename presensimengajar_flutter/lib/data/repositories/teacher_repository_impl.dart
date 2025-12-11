import 'package:pocketbase/pocketbase.dart';
import '../../core/constants.dart';
import '../../domain/repositories/teacher_repository.dart';
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
  Future<TeacherModel> updateTeacher(TeacherModel teacher) async {
    final record = await pb
        .collection(AppCollections.teachers)
        .update(teacher.id, body: teacher.toJson());
    return TeacherModel.fromRecord(record);
  }
}
