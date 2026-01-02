import 'package:equatable/equatable.dart';
import '../../../data/models/schedule_model.dart';

abstract class AdminScheduleState extends Equatable {
  const AdminScheduleState();

  @override
  List<Object> get props => [];
}

class AdminScheduleInitial extends AdminScheduleState {}

class AdminScheduleLoading extends AdminScheduleState {}

class AdminScheduleLoaded extends AdminScheduleState {
  final List<ScheduleModel> schedules;

  const AdminScheduleLoaded(this.schedules);

  @override
  List<Object> get props => [schedules];
}

class AdminScheduleOperationSuccess extends AdminScheduleState {
  final String message;

  const AdminScheduleOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AdminScheduleError extends AdminScheduleState {
  final String message;

  const AdminScheduleError(this.message);

  @override
  List<Object> get props => [message];
}
