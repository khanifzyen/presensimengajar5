import '../../data/models/schedule_model.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleModel>> getSchedulesByTeacherId(
    String teacherId, {
    String? day,
  });
  Future<ScheduleModel?> getScheduleById(String id);

  // Admin Methods
  Future<ScheduleModel> createSchedule(ScheduleModel schedule);
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(String id);
}
