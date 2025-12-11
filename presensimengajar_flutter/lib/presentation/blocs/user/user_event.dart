import 'package:equatable/equatable.dart';
import '../../../data/models/teacher_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UserGetProfile extends UserEvent {
  final String userId;

  const UserGetProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

class UserUpdateProfile extends UserEvent {
  final TeacherModel teacher;

  const UserUpdateProfile(this.teacher);

  @override
  List<Object> get props => [teacher];
}
