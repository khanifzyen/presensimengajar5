import 'package:equatable/equatable.dart';

abstract class AdminSettingsEvent extends Equatable {
  const AdminSettingsEvent();

  @override
  List<Object> get props => [];
}

class AdminSettingsFetch extends AdminSettingsEvent {}

class AdminSettingsUpdate extends AdminSettingsEvent {
  final double? latitude;
  final double? longitude;
  final double? radius;
  final int? tolerance;

  const AdminSettingsUpdate({
    this.latitude,
    this.longitude,
    this.radius,
    this.tolerance,
  });

  @override
  List<Object> get props => [
    if (latitude != null) latitude!,
    if (longitude != null) longitude!,
    if (radius != null) radius!,
    if (tolerance != null) tolerance!,
  ];
}
