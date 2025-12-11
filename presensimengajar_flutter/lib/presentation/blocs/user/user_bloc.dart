import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/teacher_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final TeacherRepository teacherRepository;

  UserBloc({required this.teacherRepository}) : super(UserInitial()) {
    on<UserGetProfile>(_onUserGetProfile);
    on<UserUpdateProfile>(_onUserUpdateProfile);
  }

  Future<void> _onUserGetProfile(
    UserGetProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final teacher = await teacherRepository.getTeacherByUserId(event.userId);
      if (teacher != null) {
        emit(UserLoaded(teacher));
      } else {
        emit(const UserError('Teacher profile not found'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserUpdateProfile(
    UserUpdateProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final updatedTeacher = await teacherRepository.updateTeacher(
        event.teacher,
      );
      emit(UserLoaded(updatedTeacher));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
