import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/schedule_repository.dart';
import 'admin_schedule_event.dart';
import 'admin_schedule_state.dart';

class AdminScheduleBloc extends Bloc<AdminScheduleEvent, AdminScheduleState> {
  final ScheduleRepository scheduleRepository;

  AdminScheduleBloc({required this.scheduleRepository})
      : super(AdminScheduleInitial()) {
    on<AdminScheduleFetch>(_onFetchSchedules);
    on<AdminScheduleAdd>(_onAddSchedule);
    on<AdminScheduleUpdate>(_onUpdateSchedule);
    on<AdminScheduleDelete>(_onDeleteSchedule);
  }

  Future<void> _onFetchSchedules(
    AdminScheduleFetch event,
    Emitter<AdminScheduleState> emit,
  ) async {
    emit(AdminScheduleLoading());
    try {
      final schedules = await scheduleRepository.getSchedulesByTeacherId(
        event.teacherId,
      );
      emit(AdminScheduleLoaded(schedules));
    } catch (e) {
      emit(AdminScheduleError(e.toString()));
    }
  }

  Future<void> _onAddSchedule(
    AdminScheduleAdd event,
    Emitter<AdminScheduleState> emit,
  ) async {
    emit(AdminScheduleLoading());
    try {
      await scheduleRepository.createSchedule(event.schedule);
      emit(const AdminScheduleOperationSuccess('Jadwal berhasil ditambahkan'));
      add(AdminScheduleFetch(event.schedule.teacherId));
    } catch (e) {
      emit(AdminScheduleError(e.toString()));
    }
  }

  Future<void> _onUpdateSchedule(
    AdminScheduleUpdate event,
    Emitter<AdminScheduleState> emit,
  ) async {
    emit(AdminScheduleLoading());
    try {
      await scheduleRepository.updateSchedule(event.schedule);
      emit(const AdminScheduleOperationSuccess('Jadwal berhasil diperbarui'));
      add(AdminScheduleFetch(event.schedule.teacherId));
    } catch (e) {
      emit(AdminScheduleError(e.toString()));
    }
  }

  Future<void> _onDeleteSchedule(
    AdminScheduleDelete event,
    Emitter<AdminScheduleState> emit,
  ) async {
    emit(AdminScheduleLoading());
    try {
      await scheduleRepository.deleteSchedule(event.id);
      emit(const AdminScheduleOperationSuccess('Jadwal berhasil dihapus'));
      add(AdminScheduleFetch(event.teacherId));
    } catch (e) {
      emit(AdminScheduleError(e.toString()));
    }
  }
}
