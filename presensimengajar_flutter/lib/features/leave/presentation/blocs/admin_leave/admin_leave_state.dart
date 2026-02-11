import 'package:equatable/equatable.dart';
import '../../../data/models/leave_request_model.dart';

abstract class AdminLeaveState extends Equatable {
  const AdminLeaveState();

  @override
  List<Object?> get props => [];
}

class AdminLeaveInitial extends AdminLeaveState {}

class AdminLeaveLoading extends AdminLeaveState {}

class AdminLeaveLoaded extends AdminLeaveState {
  final List<LeaveRequestModel> leaves;
  final List<LeaveRequestModel> allLeaves;
  final int totalPending;
  final int totalApproved;
  final int totalRejected;
  final String filterStatus;

  const AdminLeaveLoaded({
    required this.leaves,
    required this.allLeaves,
    required this.totalPending,
    required this.totalApproved,
    required this.totalRejected,
    required this.filterStatus,
  });

  @override
  List<Object?> get props => [
    leaves,
    allLeaves,
    totalPending,
    totalApproved,
    totalRejected,
    filterStatus,
  ];
}

class AdminLeaveOperationSuccess extends AdminLeaveState {
  final String message;

  const AdminLeaveOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminLeaveError extends AdminLeaveState {
  final String message;

  const AdminLeaveError(this.message);

  @override
  List<Object?> get props => [message];
}
