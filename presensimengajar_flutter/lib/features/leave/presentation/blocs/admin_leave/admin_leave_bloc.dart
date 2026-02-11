import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/leave_repository.dart';
import '../../../data/models/leave_request_model.dart';
import 'admin_leave_event.dart';
import 'admin_leave_state.dart';

class AdminLeaveBloc extends Bloc<AdminLeaveEvent, AdminLeaveState> {
  final LeaveRepository leaveRepository;

  AdminLeaveBloc({required this.leaveRepository}) : super(AdminLeaveInitial()) {
    on<AdminLeaveFetchList>(_onFetchList);
    on<AdminLeaveApprove>(_onApprove);
    on<AdminLeaveReject>(_onReject);
  }

  Future<void> _onFetchList(
    AdminLeaveFetchList event,
    Emitter<AdminLeaveState> emit,
  ) async {
    emit(AdminLeaveLoading());
    try {
      final leaves = await leaveRepository.getAllLeaves();

      // Calculate stats
      final pending = leaves.where((l) => l.status == 'pending').length;
      final approved = leaves.where((l) => l.status == 'approved').length;
      final rejected = leaves.where((l) => l.status == 'rejected').length;

      // Filter initially? Or load all and filter local?
      // Based on UI tabs, it's better to hold all data and filter view,
      // OR re-emit Loaded with filtered list based on event.
      // event.status might be passed to filter.

      List<LeaveRequestModel> filtered = leaves;
      final status = event.status ?? 'all';
      if (status != 'all') {
        filtered = leaves.where((l) => l.status == status).toList();
      }

      if (event.query != null && event.query!.isNotEmpty) {
        final q = event.query!.toLowerCase();
        filtered = filtered.where((l) {
          final name = l.teacherName?.toLowerCase() ?? '';
          final type = l.type.toLowerCase();
          return name.contains(q) || type.contains(q);
        }).toList();
      }

      emit(
        AdminLeaveLoaded(
          leaves: filtered,
          allLeaves: leaves,
          totalPending: pending,
          totalApproved: approved,
          totalRejected: rejected,
          filterStatus: status,
        ),
      );
    } catch (e) {
      emit(AdminLeaveError(e.toString()));
    }
  }

  Future<void> _onApprove(
    AdminLeaveApprove event,
    Emitter<AdminLeaveState> emit,
  ) async {
    emit(AdminLeaveLoading());
    try {
      await leaveRepository.approveLeave(event.leaveId, event.adminId);
      emit(const AdminLeaveOperationSuccess('Izin berhasil disetujui'));
      add(const AdminLeaveFetchList());
    } catch (e) {
      emit(AdminLeaveError(e.toString()));
    }
  }

  Future<void> _onReject(
    AdminLeaveReject event,
    Emitter<AdminLeaveState> emit,
  ) async {
    emit(AdminLeaveLoading());
    try {
      await leaveRepository.rejectLeave(
        event.leaveId,
        event.reason,
        event.adminId,
      );
      emit(const AdminLeaveOperationSuccess('Izin ditolak'));
      add(const AdminLeaveFetchList());
    } catch (e) {
      emit(AdminLeaveError(e.toString()));
    }
  }
}
