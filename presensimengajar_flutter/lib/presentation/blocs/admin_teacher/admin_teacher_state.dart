import 'package:equatable/equatable.dart';
import '../../../data/models/teacher_model.dart';

abstract class AdminTeacherState extends Equatable {
  const AdminTeacherState();

  @override
  List<Object?> get props => [];
}

class AdminTeacherInitial extends AdminTeacherState {}

class AdminTeacherLoading extends AdminTeacherState {}

class AdminTeacherLoaded extends AdminTeacherState {
  final List<TeacherModel> teachers;
  final String filterStatus; // 'all', 'active', 'inactive'

  const AdminTeacherLoaded({required this.teachers, this.filterStatus = 'all'});

  // Helper for stats
  int get total => teachers.length;
  int get active => teachers.where((t) => t.status == 'active').length;
  int get inactive => teachers.where((t) => t.status == 'inactive').length;
  int get newTeachers => teachers.where((t) {
    // Example: joined in last 30 days
    try {
      final join = DateTime.parse(t.joinDate);
      final now = DateTime.now();
      return now.difference(join).inDays <= 30;
    } catch (e) {
      return false;
    }
  }).length;

  @override
  List<Object?> get props => [teachers, filterStatus];
}

class AdminTeacherOperationSuccess extends AdminTeacherState {
  final String message;

  const AdminTeacherOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminTeacherError extends AdminTeacherState {
  final String message;

  const AdminTeacherError(this.message);

  @override
  List<Object?> get props => [message];
}
