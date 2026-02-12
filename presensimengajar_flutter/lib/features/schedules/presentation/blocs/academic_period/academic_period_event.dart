import 'package:equatable/equatable.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/data/models/master_models.dart';

abstract class AcademicPeriodEvent extends Equatable {
  const AcademicPeriodEvent();

  @override
  List<Object> get props => [];
}

class FetchAcademicPeriods extends AcademicPeriodEvent {}

class SelectAcademicPeriod extends AcademicPeriodEvent {
  final AcademicPeriodModel period;

  const SelectAcademicPeriod(this.period);

  @override
  List<Object> get props => [period];
}

class CreateAcademicPeriod extends AcademicPeriodEvent {
  final Map<String, dynamic> data;

  const CreateAcademicPeriod(this.data);

  @override
  List<Object> get props => [data];
}

class UpdateAcademicPeriod extends AcademicPeriodEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdateAcademicPeriod(this.id, this.data);

  @override
  List<Object> get props => [id, data];
}

class DeleteAcademicPeriod extends AcademicPeriodEvent {
  final String id;

  const DeleteAcademicPeriod(this.id);

  @override
  List<Object> get props => [id];
}

class SetActivePeriod extends AcademicPeriodEvent {
  final String id;

  const SetActivePeriod(this.id);

  @override
  List<Object> get props => [id];
}
