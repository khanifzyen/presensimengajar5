import 'package:equatable/equatable.dart';
import 'package:presensimengajar_flutter/features/leave/data/models/leave_request_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final DateTime currentDate;
  final int dateOffset;
  final Map<String, int> attendanceStats;
  final Map<String, int> categoryStats;
  final List<LeaveRequestModel> pendingLeaveRequests;
  final List<Map<String, dynamic>> realtimeMonitoring;

  const AdminLoaded({
    required this.currentDate,
    required this.dateOffset,
    required this.attendanceStats,
    required this.categoryStats,
    required this.pendingLeaveRequests,
    required this.realtimeMonitoring,
  });

  @override
  List<Object?> get props => [
    currentDate,
    dateOffset,
    attendanceStats,
    categoryStats,
    pendingLeaveRequests,
    realtimeMonitoring,
  ];

  /// Get formatted date title based on offset
  String getDateTitle() {
    if (dateOffset == 0) {
      return 'Kehadiran Hari Ini';
    } else if (dateOffset == 1) {
      return 'Kehadiran Kemarin';
    } else {
      return 'Kehadiran $dateOffset Hari Lalu';
    }
  }

  /// Get formatted date string (e.g., "10 Des")
  String getDateString() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${currentDate.day} ${months[currentDate.month - 1]}';
  }

  AdminLoaded copyWith({
    DateTime? currentDate,
    int? dateOffset,
    Map<String, int>? attendanceStats,
    Map<String, int>? categoryStats,
    List<LeaveRequestModel>? pendingLeaveRequests,
    List<Map<String, dynamic>>? realtimeMonitoring,
  }) {
    return AdminLoaded(
      currentDate: currentDate ?? this.currentDate,
      dateOffset: dateOffset ?? this.dateOffset,
      attendanceStats: attendanceStats ?? this.attendanceStats,
      categoryStats: categoryStats ?? this.categoryStats,
      pendingLeaveRequests: pendingLeaveRequests ?? this.pendingLeaveRequests,
      realtimeMonitoring: realtimeMonitoring ?? this.realtimeMonitoring,
    );
  }
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
