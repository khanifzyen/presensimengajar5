import 'package:pocketbase/pocketbase.dart';
import '../../core/constants.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final PocketBase pb;

  ScheduleRepositoryImpl(this.pb);

  @override
  Future<List<ScheduleModel>> getSchedulesByTeacherId(
    String teacherId, {
    String? day,
  }) async {
    String filter = 'teacher_id="$teacherId"';
    if (day != null) {
      filter += ' && day="$day"';
    }

    final records = await pb
        .collection(AppCollections.schedules)
        .getFullList(
          filter: filter,
          expand: 'subject_id,class_id',
          sort: 'start_time',
        );

    return records.map((r) => ScheduleModel.fromRecord(r)).toList();
  }

  @override
  Future<ScheduleModel?> getScheduleById(String id) async {
    try {
      final record = await pb
          .collection(AppCollections.schedules)
          .getOne(id, expand: 'subject_id,class_id');
      return ScheduleModel.fromRecord(record);
    } catch (e) {
      return null;
    }
  }
}
