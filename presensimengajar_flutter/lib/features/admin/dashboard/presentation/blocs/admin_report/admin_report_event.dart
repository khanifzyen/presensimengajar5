import 'package:equatable/equatable.dart';

abstract class AdminReportEvent extends Equatable {
  const AdminReportEvent();

  @override
  List<Object> get props => [];
}

class AdminReportFetch extends AdminReportEvent {
  final int month;
  final int year;

  const AdminReportFetch({required this.month, required this.year});

  @override
  List<Object> get props => [month, year];
}

class AdminReportExport extends AdminReportEvent {
  // Placeholder for export functionality
  const AdminReportExport();
}
