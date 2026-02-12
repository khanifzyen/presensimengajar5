import 'package:equatable/equatable.dart';

abstract class AdminReportEvent extends Equatable {
  const AdminReportEvent();

  @override
  List<Object> get props => [];
}

class AdminReportFetch extends AdminReportEvent {
  final int month;
  final int year;
  final String? teacherId;
  final String? category;

  const AdminReportFetch({
    required this.month,
    required this.year,
    this.teacherId,
    this.category,
  });

  @override
  List<Object> get props => [month, year, teacherId ?? '', category ?? ''];
}

class AdminReportExport extends AdminReportEvent {
  // Placeholder for export functionality
  const AdminReportExport();
}
