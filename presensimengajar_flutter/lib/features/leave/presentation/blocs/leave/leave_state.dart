import 'package:equatable/equatable.dart';
import '../../../data/models/leave_request_model.dart';

abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object> get props => [];
}

class LeaveInitial extends LeaveState {}

class LeaveLoading extends LeaveState {}

class LeaveSuccess extends LeaveState {
  final LeaveRequestModel leaveRequest;

  const LeaveSuccess(this.leaveRequest);

  @override
  List<Object> get props => [leaveRequest];
}

class LeaveHistoryLoaded extends LeaveState {
  final List<LeaveRequestModel> history;

  const LeaveHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class LeaveError extends LeaveState {
  final String message;

  const LeaveError(this.message);

  @override
  List<Object> get props => [message];
}
