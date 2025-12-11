import '../../data/models/schedule_model.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleModel>> getSchedulesByTeacherId(
    String teacherId, {
    String? day,
  });
  Future<ScheduleModel?> getScheduleById(String id);
}
