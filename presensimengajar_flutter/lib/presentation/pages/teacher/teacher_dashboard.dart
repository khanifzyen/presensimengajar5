import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';
import '../../blocs/schedule/schedule_bloc.dart';
import '../../blocs/schedule/schedule_event.dart';
import '../../blocs/schedule/schedule_state.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/attendance/attendance_event.dart';
import '../../blocs/attendance/attendance_state.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/weekly_statistics_model.dart';
import '../../../data/models/academic_period_model.dart';
import '../../blocs/academic_period/academic_period_bloc.dart';
import '../../blocs/academic_period/academic_period_state.dart';
import '../../blocs/academic_period/academic_period_event.dart';

import 'profile_page.dart';
import 'history_page.dart';
import 'permission_page.dart';
import 'teaching_page.dart';

import '../../../injection_container.dart' as di;

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  late Timer _timer;
  String _timeString = '';

  // Weekly navigation state
  DateTime _selectedWeekStart = _getWeekStart(DateTime.now());
  DateTime _selectedWeekEnd = _getWeekEnd(DateTime.now());
  int _weekOffset = 0; // 0 = current week, -1 = last week, +1 = next week
  String _selectedDay = _getCurrentDayInIndonesian();

  static String _getCurrentDayInIndonesian() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
    const days = [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu',
    ];
    return days[dayOfWeek - 1];
  }

  // Helper methods for week calculation
  static DateTime _getWeekStart(DateTime date) {
    // Get Monday of the week
    final dayOfWeek = date.weekday; // 1 = Monday, 7 = Sunday
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  static DateTime _getWeekEnd(DateTime date) {
    // Get Sunday of the week
    final dayOfWeek = date.weekday;
    return date.add(Duration(days: 7 - dayOfWeek));
  }

  void _navigateWeek(int offset) {
    setState(() {
      _weekOffset += offset;
      final newDate = DateTime.now().add(Duration(days: _weekOffset * 7));
      _selectedWeekStart = _getWeekStart(newDate);
      _selectedWeekEnd = _getWeekEnd(newDate);
    });

    // Re-fetch schedules and statistics for new week
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<ScheduleBloc>().add(
        ScheduleFetch(teacherId: userState.teacher.id),
      );

      context.read<AttendanceBloc>().add(
        AttendanceFetchWeeklyStatistics(
          teacherId: userState.teacher.id,
          weekStart: _selectedWeekStart,
          weekEnd: _selectedWeekEnd,
        ),
      );
    }
  }

  String _getWeekLabel() {
    if (_weekOffset == 0) {
      return 'Jadwal Minggu Ini';
    } else if (_weekOffset == -1) {
      return 'Jadwal 1 Minggu Lalu';
    } else if (_weekOffset == 1) {
      return 'Jadwal 1 Minggu Kedepan';
    } else if (_weekOffset < -1) {
      return 'Jadwal ${_weekOffset.abs()} Minggu Lalu';
    } else {
      return 'Jadwal $_weekOffset Minggu Kedepan';
    }
  }

  String _getWeekDateRange() {
    final startDay = _selectedWeekStart.day;
    final endDay = _selectedWeekEnd.day;
    final startMonth = DateFormat('MMM', 'id_ID').format(_selectedWeekStart);
    final endMonth = DateFormat('MMM', 'id_ID').format(_selectedWeekEnd);
    final year = _selectedWeekEnd.year;

    if (_selectedWeekStart.month == _selectedWeekEnd.month) {
      return '$startDay-$endDay $endMonth $year';
    } else {
      return '$startDay $startMonth - $endDay $endMonth $year';
    }
  }

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _updateTime(),
    );

    // Fetch user profile on init
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserBloc>().add(UserGetProfile(authState.userId));
    }

    // Fetch academic periods
    context.read<AcademicPeriodBloc>().add(FetchAcademicPeriods());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('HH:mm:ss').format(now);
    if (mounted) {
      setState(() {
        _timeString = formattedTime;
      });
    }
  }

  String _getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final time = hour + minute / 60.0;

    if (time >= 0.0 && time <= 10.5) {
      return 'Selamat Pagi';
    } else if (time > 10.5 && time <= 14.5) {
      return 'Selamat Siang';
    } else if (time > 14.5 && time <= 18.0) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            // Fetch all schedules for the teacher (no day filter for weekly view)
            context.read<ScheduleBloc>().add(
              ScheduleFetch(teacherId: state.teacher.id),
            );

            // Fetch weekly statistics
            context.read<AttendanceBloc>().add(
              AttendanceFetchWeeklyStatistics(
                teacherId: state.teacher.id,
                weekStart: _selectedWeekStart,
                weekEnd: _selectedWeekEnd,
              ),
            );
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memuat profil: ${state.message}')),
            );
          }
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            BlocProvider(
              create: (context) => di.sl<AttendanceBloc>(),
              child: const HistoryPage(),
            ),
            const PermissionPage(),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history, weight: 700),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Izin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Scan/Attendance
        },
        backgroundColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
        child: const Icon(FontAwesomeIcons.camera, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.read<UserBloc>().add(UserGetProfile(authState.userId));
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Blue Header Background
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),

                // Header Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        if (state is UserLoaded) {
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                backgroundImage: state.teacher.photo.isNotEmpty
                                    ? NetworkImage(
                                        state.teacher.getPhotoUrl(
                                          dotenv.env['POCKETBASE_URL'] ??
                                              'https://pb-presensi.pasarjepara.com',
                                        ),
                                      )
                                    : null,
                                child: state.teacher.photo.isEmpty
                                    ? Text(
                                        state.teacher.name[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Halo, ${_getGreeting()}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    state.teacher.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Stack(
                                children: [
                                  const Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else if (state is UserLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        } else if (state is UserError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Gagal memuat profil: ${state.message}',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),

                // Time Card (Overlapping)
                Padding(
                  padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _timeString,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'EEEE, d MMMM yyyy',
                            'id_ID',
                          ).format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Jam Ajar',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '05:30',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tepat Waktu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Kelas Saat Ini Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kelas Saat Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: const Border(
                        left: BorderSide(color: Colors.green, width: 6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Matematika Wajib',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kelas XII IPA 1 • 07:00 - 08:30',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text(
                              'CHECK-OUT KELAS',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Sedang berlangsung...',
                            style: TextStyle(
                              color: Colors.green,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Jadwal Minggu Ini Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week Navigation Header
                  Row(
                    children: [
                      // Left Arrow
                      IconButton(
                        onPressed: () => _navigateWeek(-1),
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        color: const Color(0xFF1E3A8A),
                      ),

                      // Week Label and Date Range
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _getWeekLabel(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getWeekDateRange(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Right Arrow
                      IconButton(
                        onPressed: () => _navigateWeek(1),
                        icon: const Icon(Icons.arrow_forward_ios, size: 20),
                        color: const Color(0xFF1E3A8A),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Day Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          [
                            'senin',
                            'selasa',
                            'rabu',
                            'kamis',
                            'jumat',
                            'sabtu',
                          ].map((day) {
                            final isSelected = day == _selectedDay;
                            final displayDay =
                                day[0].toUpperCase() + day.substring(1);
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedDay = day;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? const Color(0xFF1E3A8A)
                                      : Colors.white,
                                  foregroundColor: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isSelected
                                          ? const Color(0xFF1E3A8A)
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(displayDay),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Schedule List with Attendance
                  BlocBuilder<AcademicPeriodBloc, AcademicPeriodState>(
                    builder: (context, periodState) {
                      if (periodState is AcademicPeriodLoading ||
                          periodState is AcademicPeriodInitial) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      AcademicPeriodModel? activePeriod;
                      if (periodState is AcademicPeriodLoaded) {
                        try {
                          activePeriod = periodState.periods.firstWhere(
                            (p) => p.isActive,
                          );
                        } catch (_) {
                          // Fallback to first if no active found
                          if (periodState.periods.isNotEmpty) {
                            activePeriod = periodState.periods.first;
                          }
                        }
                      }

                      if (activePeriod == null) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Tidak ada data kurikulum'),
                          ),
                        );
                      }

                      // Check if selected week is within active period
                      final periodStart = DateTime.parse(
                        activePeriod.startDate,
                      );
                      final periodEnd = DateTime.parse(activePeriod.endDate);

                      final displayStart = DateTime(
                        _selectedWeekStart.year,
                        _selectedWeekStart.month,
                        _selectedWeekStart.day,
                      );
                      final displayEnd = DateTime(
                        _selectedWeekEnd.year,
                        _selectedWeekEnd.month,
                        _selectedWeekEnd.day,
                      );

                      // Check intersection
                      final isWithinPeriod =
                          !(displayEnd.isBefore(periodStart) ||
                              displayStart.isAfter(periodEnd));

                      if (!isWithinPeriod) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak Ada Jadwal Kurikulum ${activePeriod.name} Ini',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return BlocListener<ScheduleBloc, ScheduleState>(
                        listener: (context, state) {
                          if (state is ScheduleLoaded &&
                              state.schedules.isNotEmpty) {
                            // Filter schedules by active period
                            final validSchedules = state.schedules
                                .where((s) => s.periodId == activePeriod?.id)
                                .toList();

                            if (validSchedules.isNotEmpty) {
                              // Extract schedule IDs and fetch attendance
                              final scheduleIds = validSchedules
                                  .map((s) => s.id)
                                  .toList();

                              final userState = context.read<UserBloc>().state;
                              if (userState is UserLoaded) {
                                context.read<AttendanceBloc>().add(
                                  AttendanceFetchForSchedules(
                                    teacherId: userState.teacher.id,
                                    scheduleIds: scheduleIds,
                                    startDate: _selectedWeekStart,
                                    endDate: _selectedWeekEnd,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: BlocBuilder<ScheduleBloc, ScheduleState>(
                          builder: (context, scheduleState) {
                            if (scheduleState is ScheduleLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (scheduleState is ScheduleLoaded) {
                              // First filter by active period
                              final periodSchedules = scheduleState.schedules
                                  .where((s) => s.periodId == activePeriod?.id)
                                  .toList();

                              if (periodSchedules.isEmpty) {
                                return Center(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/no_data.png',
                                        width: 200,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Belum ada jadwal di kurikulum ${activePeriod?.name}',
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Then filter by day
                              final daySchedules = periodSchedules
                                  .where(
                                    (schedule) => schedule.day == _selectedDay,
                                  )
                                  .toList();

                              if (daySchedules.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      'Tidak ada jadwal di hari ${_selectedDay[0].toUpperCase()}${_selectedDay.substring(1)}',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                  ),
                                );
                              }

                              // Nest AttendanceBloc builder to get attendance data
                              return BlocBuilder<
                                AttendanceBloc,
                                AttendanceState
                              >(
                                builder: (context, attendanceState) {
                                  Map<String, AttendanceModel> attendanceMap =
                                      {};
                                  if (attendanceState
                                      is AttendanceScheduleMapLoaded) {
                                    attendanceMap =
                                        attendanceState.attendanceMap;
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: daySchedules.length,
                                    itemBuilder: (context, index) {
                                      final schedule = daySchedules[index];
                                      final attendance =
                                          attendanceMap[schedule.id];

                                      // Get subject name from expanded data
                                      String subjectName = 'Mata Pelajaran';
                                      if (schedule.subject != null) {
                                        subjectName = schedule.subject!
                                            .getStringValue('name');
                                      }

                                      // Get class name from expanded data
                                      String className = 'Kelas';
                                      if (schedule.classInfo != null) {
                                        className = schedule.classInfo!
                                            .getStringValue('name');
                                      }

                                      // Determine status and button
                                      String statusLabel;
                                      Color statusColor;
                                      Widget? actionButton;

                                      if (attendance == null) {
                                        // No attendance record
                                        statusLabel = 'Menunggu';
                                        statusColor = Colors.grey;
                                        actionButton = ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TeachingPage(
                                                      schedule: schedule,
                                                    ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1E3A8A,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Check-In',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      } else if (attendance.checkIn != null &&
                                          attendance.checkOut == null) {
                                        // Checked in, not checked out
                                        statusLabel = 'Sedang Mengajar';
                                        statusColor = Colors.orange;
                                        actionButton = ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TeachingPage(
                                                      schedule: schedule,
                                                    ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Check-Out',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      } else {
                                        // Checked out (completed)
                                        final checkInTime = DateFormat('HH:mm')
                                            .format(
                                              DateTime.parse(
                                                attendance.checkIn!,
                                              ),
                                            );
                                        final checkOutTime = DateFormat('HH:mm')
                                            .format(
                                              DateTime.parse(
                                                attendance.checkOut!,
                                              ),
                                            );
                                        statusLabel =
                                            'Hadir ($checkInTime - $checkOutTime)';
                                        statusColor = const Color(0xFF10B981);
                                        actionButton =
                                            null; // No button for completed
                                      }

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: const Border(
                                            left: BorderSide(
                                              color: Color(0xFF10B981),
                                              width: 6,
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              // Time Column
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    schedule.startTime,
                                                    style: const TextStyle(
                                                      color: Color(0xFF1E3A8A),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const Text(
                                                    '-',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    schedule.endTime,
                                                    style: const TextStyle(
                                                      color: Color(0xFF1E3A8A),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 16),

                                              // Divider
                                              Container(
                                                height: 50,
                                                width: 1,
                                                color: Colors.grey[300],
                                              ),
                                              const SizedBox(width: 16),

                                              // Details Column
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '$subjectName - $className',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          schedule.room.isEmpty
                                                              ? 'Ruang Kelas'
                                                              : schedule.room,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: statusColor
                                                                .withValues(
                                                                  alpha: 0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            statusLabel,
                                                            style: TextStyle(
                                                              color:
                                                                  statusColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        if (actionButton !=
                                                            null) ...[
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          actionButton,
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            } else if (scheduleState is ScheduleError) {
                              return Center(
                                child: Text('Error: ${scheduleState.message}'),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Weekly Statistics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistik Minggu Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AcademicPeriodBloc, AcademicPeriodState>(
                    builder: (context, periodState) {
                      AcademicPeriodModel? activePeriod;
                      if (periodState is AcademicPeriodLoaded) {
                        try {
                          activePeriod = periodState.periods.firstWhere(
                            (p) => p.isActive,
                          );
                        } catch (_) {
                          if (periodState.periods.isNotEmpty) {
                            activePeriod = periodState.periods.first;
                          }
                        }
                      }

                      if (activePeriod != null) {
                        // Check intersection
                        final periodStart = DateTime.parse(
                          activePeriod.startDate,
                        );
                        final periodEnd = DateTime.parse(activePeriod.endDate);

                        final displayStart = DateTime(
                          _selectedWeekStart.year,
                          _selectedWeekStart.month,
                          _selectedWeekStart.day,
                        );
                        final displayEnd = DateTime(
                          _selectedWeekEnd.year,
                          _selectedWeekEnd.month,
                          _selectedWeekEnd.day,
                        );

                        final isWithinPeriod =
                            !(displayEnd.isBefore(periodStart) ||
                                displayStart.isAfter(periodEnd));

                        if (!isWithinPeriod) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak Ada Statistik Minggu ini di Kurikulum ${activePeriod.name}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }

                      return BlocBuilder<AttendanceBloc, AttendanceState>(
                        builder: (context, state) {
                          if (state is AttendanceStatisticsLoaded) {
                            return _buildStatisticsGrid(state.statistics);
                          }
                          // Show empty state while loading
                          return _buildStatisticsGrid(
                            WeeklyStatisticsModel.empty(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  // Helper method to build statistics grid
  // Helper method to build statistics grid
  Widget _buildStatisticsGrid(WeeklyStatisticsModel statistics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio:
          1.2, // Decreased ratio to increase height and fix overflow
      children: [
        _buildStatBox(
          label: 'Kelas Diampu',
          value: statistics.classesAttended,
          color: Colors.green,
          icon: Icons.check_circle,
        ),
        _buildStatBox(
          label: 'Terlambat',
          value: statistics.lateArrivals,
          color: Colors.orange,
          icon: Icons.access_time,
        ),
        _buildStatBox(
          label: 'Izin',
          value: statistics.leaveRequests,
          color: Colors.blue,
          icon: Icons.event_note,
        ),
        _buildStatBox(
          label: 'Alpha',
          value: statistics.alpha,
          color: Colors.red,
          icon: Icons.cancel,
        ),
      ],
    );
  }

  // Helper method to build individual stat box
  Widget _buildStatBox({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
