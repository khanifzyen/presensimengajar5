import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository attendanceRepository;

  AttendanceBloc({required this.attendanceRepository})
    : super(AttendanceInitial()) {
    on<AttendanceCheckIn>(_onAttendanceCheckIn);
    on<AttendanceCheckOut>(_onAttendanceCheckOut);
    on<AttendanceFetchHistory>(_onAttendanceFetchHistory);
  }

  Future<void> _onAttendanceCheckIn(
    AttendanceCheckIn event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendance = await attendanceRepository.checkIn(
        teacherId: event.teacherId,
        scheduleId: event.scheduleId,
        latitude: event.latitude,
        longitude: event.longitude,
        photo: event.photo,
        notes: event.notes,
      );
      emit(AttendanceSuccess(attendance));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onAttendanceCheckOut(
    AttendanceCheckOut event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendance = await attendanceRepository.checkOut(
        attendanceId: event.attendanceId,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(AttendanceSuccess(attendance));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onAttendanceFetchHistory(
    AttendanceFetchHistory event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final history = await attendanceRepository.getAttendanceHistory(
        event.teacherId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(AttendanceHistoryLoaded(history));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
