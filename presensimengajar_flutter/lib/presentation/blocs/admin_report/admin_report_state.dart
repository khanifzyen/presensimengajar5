import 'package:equatable/equatable.dart';

abstract class AdminReportState extends Equatable {
  const AdminReportState();

  @override
  List<Object> get props => [];
}

class AdminReportInitial extends AdminReportState {}

class AdminReportLoading extends AdminReportState {}

class AdminReportLoaded extends AdminReportState {
  final List<Map<String, dynamic>> reportData;
  final int month;
  final int year;

  const AdminReportLoaded({
    required this.reportData,
    required this.month,
    required this.year,
  });

  @override
  List<Object> get props => [reportData, month, year];
}

class AdminReportError extends AdminReportState {
  final String message;

  const AdminReportError(this.message);

  @override
  List<Object> get props => [message];
}
