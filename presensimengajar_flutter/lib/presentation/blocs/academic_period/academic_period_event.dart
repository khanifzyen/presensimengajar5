import 'package:equatable/equatable.dart';
import '../../../data/models/academic_period_model.dart';

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
