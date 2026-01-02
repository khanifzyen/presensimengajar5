import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/teacher_repository_impl.dart';
import 'data/repositories/schedule_repository_impl.dart';
import 'data/repositories/attendance_repository_impl.dart';
import 'data/repositories/leave_repository_impl.dart';
import 'data/repositories/admin_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';

import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/teacher_repository.dart';
import 'domain/repositories/schedule_repository.dart';
import 'domain/repositories/attendance_repository.dart';
import 'domain/repositories/leave_repository.dart';
import 'domain/repositories/admin_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/repositories/notification_repository.dart';

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/blocs/schedule/schedule_bloc.dart';
import 'presentation/blocs/attendance/attendance_bloc.dart';
import 'presentation/blocs/leave/leave_bloc.dart';
import 'presentation/blocs/notification/notification_bloc.dart';
import 'presentation/blocs/admin/admin_bloc.dart';
import 'presentation/blocs/academic_period/academic_period_bloc.dart';
import 'presentation/blocs/admin_teacher/admin_teacher_bloc.dart';
import 'presentation/blocs/admin_leave/admin_leave_bloc.dart';
import 'presentation/blocs/admin_report/admin_report_bloc.dart';
import 'presentation/blocs/admin_schedule/admin_schedule_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // PocketBase
  final pocketbaseUrl = dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';
  sl.registerLazySingleton(() => PocketBase(pocketbaseUrl));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<LeaveRepository>(() => LeaveRepositoryImpl(sl()));
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl()));
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  // Blocs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => UserBloc(teacherRepository: sl()));
  sl.registerFactory(() => ScheduleBloc(scheduleRepository: sl()));
  sl.registerFactory(
    () => AttendanceBloc(attendanceRepository: sl(), settingsRepository: sl()),
  );
  sl.registerFactory(() => LeaveBloc(leaveRepository: sl()));
  sl.registerFactory(() => NotificationBloc(notificationRepository: sl()));
  sl.registerFactory(() => AdminBloc(adminRepository: sl()));
  sl.registerFactory(() => AcademicPeriodBloc(sl()));
  sl.registerFactory(() => AdminTeacherBloc(teacherRepository: sl()));
  sl.registerFactory(() => AdminLeaveBloc(leaveRepository: sl()));
  sl.registerFactory(() => AdminReportBloc(adminRepository: sl()));
  sl.registerFactory(() => AdminScheduleBloc(scheduleRepository: sl()));
}
