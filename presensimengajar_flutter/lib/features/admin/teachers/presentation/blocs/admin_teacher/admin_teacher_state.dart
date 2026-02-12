import 'package:equatable/equatable.dart';
import 'package:presensimengajar_flutter/features/teachers/data/models/teacher_model.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/data/models/master_models.dart';

abstract class AdminTeacherState extends Equatable {
  const AdminTeacherState();

  @override
  List<Object?> get props => [];
}

class AdminTeacherInitial extends AdminTeacherState {}

class AdminTeacherLoading extends AdminTeacherState {}

class AdminTeacherLoaded extends AdminTeacherState {
  final List<TeacherModel> teachers;
  final List<TeacherModel> allTeachers; // Source of truth
  final List<SubjectModel> subjects;
  final String filterStatus; // 'all', 'active', 'inactive'

  const AdminTeacherLoaded({
    required this.teachers,
    required this.allTeachers,
    this.subjects = const [],
    this.filterStatus = 'all',
  });

  // Helper for stats - Use allTeachers for stats?
  // Requirement: "sebaiknya langsung pencarian di lokal saja".
  // Stats typically show total from DB, not filtered search results.
  // So using allTeachers for stats is better.
  int get total => allTeachers.length;
  int get active => allTeachers.where((t) => t.status == 'active').length;
  int get inactive => allTeachers.where((t) => t.status == 'inactive').length;
  int get newTeachers => allTeachers.where((t) {
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
  List<Object?> get props => [teachers, allTeachers, subjects, filterStatus];
}

class AdminTeacherOperationSuccess extends AdminTeacherState {
  final String message;

  const AdminTeacherOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminTeacherExportSuccess extends AdminTeacherState {
  final String path;
  final String message;

  const AdminTeacherExportSuccess(this.path, this.message);

  @override
  List<Object?> get props => [path, message];
}

class AdminTeacherError extends AdminTeacherState {
  final String message;

  const AdminTeacherError(this.message);

  @override
  List<Object?> get props => [message];
}
