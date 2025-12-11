import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'injection_container.dart' as di;
import 'core/theme.dart';
import 'routes/app_router.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/blocs/schedule/schedule_bloc.dart';
import 'presentation/blocs/attendance/attendance_bloc.dart';
import 'presentation/blocs/leave/leave_bloc.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<UserBloc>()),
        BlocProvider(create: (_) => di.sl<ScheduleBloc>()),
        BlocProvider(create: (_) => di.sl<AttendanceBloc>()),
        BlocProvider(create: (_) => di.sl<LeaveBloc>()),
        // Add other global blocs here if needed
      ],
      child: MaterialApp.router(
        title: 'EduPresence',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
