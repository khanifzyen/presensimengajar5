import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
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
}
