import 'package:equatable/equatable.dart';
import '../../../data/models/schedule_model.dart';

abstract class AdminScheduleEvent extends Equatable {
  const AdminScheduleEvent();

  @override
  List<Object> get props => [];
}

class AdminScheduleFetch extends AdminScheduleEvent {
  final String teacherId;

  const AdminScheduleFetch(this.teacherId);

  @override
  List<Object> get props => [teacherId];
}

class AdminScheduleAdd extends AdminScheduleEvent {
  final ScheduleModel schedule;

  const AdminScheduleAdd(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class AdminScheduleUpdate extends AdminScheduleEvent {
  final ScheduleModel schedule;

  const AdminScheduleUpdate(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class AdminScheduleDelete extends AdminScheduleEvent {
  final String id;
  final String teacherId; // For refreshing list

  const AdminScheduleDelete(this.id, this.teacherId);

  @override
  List<Object> get props => [id, teacherId];
}

class AdminScheduleCopy extends AdminScheduleEvent {
  final String teacherId;
  final String sourcePeriodId;
  final String targetPeriodId;

  const AdminScheduleCopy({
    required this.teacherId,
    required this.sourcePeriodId,
    required this.targetPeriodId,
  });

  @override
  List<Object> get props => [teacherId, sourcePeriodId, targetPeriodId];
}
