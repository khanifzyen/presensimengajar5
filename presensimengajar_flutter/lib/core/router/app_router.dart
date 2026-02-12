import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/home/presentation/pages/teacher_dashboard.dart';
import '../../features/attendance/presentation/pages/teaching_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/guide_page.dart';
import '../../features/profile/presentation/pages/about_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/common/presentation/pages/attachment_viewer_page.dart';
import '../../features/admin/dashboard/presentation/pages/admin_dashboard.dart';
import '../../features/admin/teachers/presentation/pages/teacher_form_page.dart';
import '../../features/schedules/presentation/pages/admin_schedule_page.dart';
import '../../features/schedules/presentation/pages/admin_schedule_form_page.dart';
import '../../features/schedules/data/models/schedule_model.dart';
import '../../features/attendance/data/models/attendance_model.dart';
import '../../features/teachers/data/models/teacher_model.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/teaching',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final schedule = extras['schedule'] as ScheduleModel;
          final attendance = extras['attendance'] as AttendanceModel?;
          return TeachingPage(schedule: schedule, attendance: attendance);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(path: '/guide', builder: (context, state) => const GuidePage()),
      GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/attachment-viewer',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final url = extras['url'] as String;
          final fileName = extras['fileName'] as String;
          final isPdf = extras['isPdf'] as bool;
          return AttachmentViewerPage(
            url: url,
            fileName: fileName,
            isPdf: isPdf,
          );
        },
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/teacher-form',
        builder: (context, state) {
          final teacher = state.extra as TeacherModel?;
          return TeacherFormPage(teacher: teacher);
        },
      ),
      GoRoute(
        path: '/admin-schedule',
        builder: (context, state) {
          final teacher = state.extra as TeacherModel;
          return AdminSchedulePage(teacher: teacher);
        },
      ),
      GoRoute(
        path: '/admin-schedule-form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return AdminScheduleFormPage(
            teacher: extra['teacher'] as TeacherModel,
            schedule: extra['schedule'] as ScheduleModel?,
          );
        },
      ),
    ],
  );
}
