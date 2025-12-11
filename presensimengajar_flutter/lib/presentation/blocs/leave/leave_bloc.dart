import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/leave_repository.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository leaveRepository;

  LeaveBloc({required this.leaveRepository}) : super(LeaveInitial()) {
    on<LeaveRequestSubmit>(_onLeaveRequestSubmit);
    on<LeaveFetchHistory>(_onLeaveFetchHistory);
  }

  Future<void> _onLeaveRequestSubmit(
    LeaveRequestSubmit event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leaveRequest = await leaveRepository.requestLeave(
        teacherId: event.teacherId,
        type: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
        reason: event.reason,
        attachment: event.attachment,
      );
      emit(LeaveSuccess(leaveRequest));
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }

  Future<void> _onLeaveFetchHistory(
    LeaveFetchHistory event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final history = await leaveRepository.getLeaveHistory(event.teacherId);
      emit(LeaveHistoryLoaded(history));
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }
}
