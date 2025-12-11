import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/teacher_repository_impl.dart';
import 'data/repositories/schedule_repository_impl.dart';
import 'data/repositories/attendance_repository_impl.dart';
import 'data/repositories/leave_repository_impl.dart';

import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/teacher_repository.dart';
import 'domain/repositories/schedule_repository.dart';
import 'domain/repositories/attendance_repository.dart';
import 'domain/repositories/leave_repository.dart';

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

  // Blocs (To be registered later)
}
