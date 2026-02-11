import 'package:equatable/equatable.dart';
import '../../../../teachers/data/models/teacher_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final TeacherModel teacher;

  const UserLoaded(this.teacher);

  @override
  List<Object> get props => [teacher];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}
