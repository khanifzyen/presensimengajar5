import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/domain/repositories/admin_repository.dart';
import 'package:presensimengajar_flutter/features/leave/data/models/leave_request_model.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository adminRepository;
  int _currentDateOffset = 0;

  AdminBloc({required this.adminRepository}) : super(const AdminInitial()) {
    on<AdminLoadDashboard>(_onLoadDashboard);
    on<AdminChangeDateOffset>(_onChangeDateOffset);
    on<AdminRefreshData>(_onRefreshData);
  }

  Future<void> _onLoadDashboard(
    AdminLoadDashboard event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    await _loadDashboardData(emit, _currentDateOffset);
  }

  Future<void> _onChangeDateOffset(
    AdminChangeDateOffset event,
    Emitter<AdminState> emit,
  ) async {
    _currentDateOffset = event.offset;
    emit(const AdminLoading());
    await _loadDashboardData(emit, _currentDateOffset);
  }

  Future<void> _onRefreshData(
    AdminRefreshData event,
    Emitter<AdminState> emit,
  ) async {
    await _loadDashboardData(emit, _currentDateOffset);
  }

  Future<void> _loadDashboardData(
    Emitter<AdminState> emit,
    int dateOffset,
  ) async {
    try {
      // Calculate the target date based on offset
      final targetDate = DateTime.now().subtract(Duration(days: dateOffset));

      // Fetch all data in parallel
      final results = await Future.wait([
        adminRepository.getDailyAttendanceStats(targetDate),
        adminRepository.getTeacherCategoryStats(),
        adminRepository.getPendingLeaveRequests(),
        adminRepository.getRealtimeMonitoring(targetDate),
      ]);

      emit(
        AdminLoaded(
          currentDate: targetDate,
          dateOffset: dateOffset,
          attendanceStats: results[0] as Map<String, int>,
          categoryStats: results[1] as Map<String, int>,
          pendingLeaveRequests: (results[2] as List).cast<LeaveRequestModel>(),
          realtimeMonitoring: results[3] as List<Map<String, dynamic>>,
        ),
      );
    } catch (e) {
      emit(AdminError('Gagal memuat data dashboard: ${e.toString()}'));
    }
  }
}
