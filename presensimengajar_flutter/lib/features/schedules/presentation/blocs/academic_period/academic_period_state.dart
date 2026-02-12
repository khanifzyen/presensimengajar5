import 'package:equatable/equatable.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/data/models/master_models.dart';

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

class AcademicPeriodSuccess extends AcademicPeriodState {
  final String message;

  const AcademicPeriodSuccess(this.message);

  @override
  List<Object> get props => [message];
}
