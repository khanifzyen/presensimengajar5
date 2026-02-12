import 'package:equatable/equatable.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object> get props => [];
}

class FetchGuides extends ContentEvent {}

class FetchAppInfo extends ContentEvent {}
