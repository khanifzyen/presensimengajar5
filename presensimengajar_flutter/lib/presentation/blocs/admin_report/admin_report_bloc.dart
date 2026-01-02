import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/admin_repository.dart';
import 'admin_report_event.dart';
import 'admin_report_state.dart';

class AdminReportBloc extends Bloc<AdminReportEvent, AdminReportState> {
  final AdminRepository adminRepository;

  AdminReportBloc({required this.adminRepository})
      : super(AdminReportInitial()) {
    on<AdminReportFetch>(_onFetchReport);
  }

  Future<void> _onFetchReport(
    AdminReportFetch event,
    Emitter<AdminReportState> emit,
  ) async {
    emit(AdminReportLoading());
    try {
      final data = await adminRepository.getMonthlyAttendanceReport(
        event.month,
        event.year,
      );
      emit(
        AdminReportLoaded(
          reportData: data,
          month: event.month,
          year: event.year,
        ),
      );
    } catch (e) {
      emit(AdminReportError(e.toString()));
    }
  }
}
