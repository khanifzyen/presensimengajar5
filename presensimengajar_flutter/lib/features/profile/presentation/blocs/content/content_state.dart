import 'package:equatable/equatable.dart';

abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class GuidesLoaded extends ContentState {
  final List<Map<String, dynamic>> guides;

  const GuidesLoaded(this.guides);

  @override
  List<Object> get props => [guides];
}

class AppInfoLoaded extends ContentState {
  final Map<String, dynamic> appInfo;

  const AppInfoLoaded(this.appInfo);

  @override
  List<Object> get props => [appInfo];
}

class ContentError extends ContentState {
  final String message;

  const ContentError(this.message);

  @override
  List<Object> get props => [message];
}
