import 'package:equatable/equatable.dart';

abstract class AdminSettingsState extends Equatable {
  const AdminSettingsState();

  @override
  List<Object?> get props => [];
}

class AdminSettingsInitial extends AdminSettingsState {}

class AdminSettingsLoading extends AdminSettingsState {}

class AdminSettingsLoaded extends AdminSettingsState {
  final double latitude;
  final double longitude;
  final double radius;
  final int tolerance;

  const AdminSettingsLoaded({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.tolerance,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius, tolerance];
}

class AdminSettingsError extends AdminSettingsState {
  final String message;

  const AdminSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminSettingsSuccess extends AdminSettingsState {
  final String message;

  const AdminSettingsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
