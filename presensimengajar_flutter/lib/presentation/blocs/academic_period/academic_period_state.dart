import 'package:equatable/equatable.dart';
import '../../../data/models/academic_period_model.dart';

abstract class AcademicPeriodState extends Equatable {
  const AcademicPeriodState();

  @override
  List<Object?> get props => [];
}

class AcademicPeriodInitial extends AcademicPeriodState {}

class AcademicPeriodLoading extends AcademicPeriodState {}

class AcademicPeriodLoaded extends AcademicPeriodState {
  final List<AcademicPeriodModel> periods;
  final AcademicPeriodModel? selectedPeriod;

  const AcademicPeriodLoaded({required this.periods, this.selectedPeriod});

  @override
  List<Object?> get props => [periods, selectedPeriod];
}

class AcademicPeriodError extends AcademicPeriodState {
  final String message;

  const AcademicPeriodError(this.message);

  @override
  List<Object> get props => [message];
}
