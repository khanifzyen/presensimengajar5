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

  @override
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final record = await pb.collection(AppCollections.schedules).create(
          body: schedule.toJson(),
        );
    return ScheduleModel.fromRecord(record);
  }

  @override
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule) async {
    final record = await pb.collection(AppCollections.schedules).update(
          schedule.id,
          body: schedule.toJson(),
        );
    return ScheduleModel.fromRecord(record);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await pb.collection(AppCollections.schedules).delete(id);
  }

  @override
  Future<void> copySchedules({
    required String teacherId,
    required String sourcePeriodId,
    required String targetPeriodId,
  }) async {
    // 1. Fetch schedules from source period
    final sourceSchedules = await pb
        .collection(AppCollections.schedules)
        .getFullList(
          filter: 'teacher_id="$teacherId" && period_id="$sourcePeriodId"',
        );

    // 2. Iterate and create for target period
    for (final record in sourceSchedules) {
      final sourceData = record.data;
      // Remove system fields
      sourceData.remove('id');
      sourceData.remove('created');
      sourceData.remove('updated');
      sourceData.remove('collectionId');
      sourceData.remove('collectionName');
      sourceData.remove('expand');

      // Update period_id
      sourceData['period_id'] = targetPeriodId;

      // Create new record
      await pb.collection(AppCollections.schedules).create(body: sourceData);
    }
  }
}
