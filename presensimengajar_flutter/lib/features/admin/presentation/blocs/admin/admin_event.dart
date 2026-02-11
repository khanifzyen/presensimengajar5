import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load dashboard data for the current date offset
class AdminLoadDashboard extends AdminEvent {
  const AdminLoadDashboard();
}

/// Event to change the date offset (0 = today, 1 = yesterday, 2 = 2 days ago, etc.)
class AdminChangeDateOffset extends AdminEvent {
  final int offset;

  const AdminChangeDateOffset(this.offset);

  @override
  List<Object?> get props => [offset];
}

/// Event to refresh dashboard data
class AdminRefreshData extends AdminEvent {
  const AdminRefreshData();
}
