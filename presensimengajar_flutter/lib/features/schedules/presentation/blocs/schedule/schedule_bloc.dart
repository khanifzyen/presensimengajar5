import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/schedule_repository.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository scheduleRepository;

  ScheduleBloc({required this.scheduleRepository}) : super(ScheduleInitial()) {
    on<ScheduleFetch>(_onScheduleFetch);
  }

  Future<void> _onScheduleFetch(
    ScheduleFetch event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      final schedules = await scheduleRepository.getSchedulesByTeacherId(
        event.teacherId,
        day: event.day,
      );
      emit(ScheduleLoaded(schedules));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}
