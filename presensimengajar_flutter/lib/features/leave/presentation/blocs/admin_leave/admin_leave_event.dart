import 'package:equatable/equatable.dart';

abstract class AdminLeaveEvent extends Equatable {
  const AdminLeaveEvent();

  @override
  List<Object> get props => [];
}

class AdminLeaveFetchList extends AdminLeaveEvent {
  final String? status;
  final String? query;

  const AdminLeaveFetchList({this.status, this.query});

  @override
  List<Object> get props => [status ?? '', query ?? ''];
}

class AdminLeaveApprove extends AdminLeaveEvent {
  final String leaveId;
  final String adminId;

  const AdminLeaveApprove({required this.leaveId, required this.adminId});

  @override
  List<Object> get props => [leaveId, adminId];
}

class AdminLeaveReject extends AdminLeaveEvent {
  final String leaveId;
  final String reason;
  final String adminId;

  const AdminLeaveReject({
    required this.leaveId,
    required this.reason,
    required this.adminId,
  });

  @override
  List<Object> get props => [leaveId, reason, adminId];
}
