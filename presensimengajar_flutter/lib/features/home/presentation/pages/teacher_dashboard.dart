import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../auth/presentation/blocs/auth/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth/auth_state.dart';
import '../../../profile/presentation/blocs/user/user_bloc.dart';
import '../../../profile/presentation/blocs/user/user_event.dart';
import '../../../profile/presentation/blocs/user/user_state.dart';
import '../../../schedules/presentation/blocs/schedule/schedule_bloc.dart';
import '../../../schedules/presentation/blocs/schedule/schedule_event.dart';
import '../../../schedules/presentation/blocs/schedule/schedule_state.dart';
import '../../../attendance/presentation/blocs/attendance/attendance_bloc.dart';
import '../../../attendance/presentation/blocs/attendance/attendance_event.dart';
import '../../../attendance/presentation/blocs/attendance/attendance_state.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../attendance/data/models/weekly_statistics_model.dart';
import '../../../admin/data/models/master_models.dart';
import '../../../schedules/presentation/blocs/academic_period/academic_period_bloc.dart';
import '../../../schedules/presentation/blocs/academic_period/academic_period_state.dart';
import '../../../schedules/presentation/blocs/academic_period/academic_period_event.dart';
import '../../../schedules/data/models/schedule_model.dart';

import '../../../profile/presentation/pages/profile_page.dart';
import '../../../attendance/presentation/pages/history_page.dart';
import '../../../leave/presentation/pages/permission_page.dart';

import '../../../../core/di/injection.dart' as di;

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  late Timer _timer;
  String _timeString = '';
  Map<String, AttendanceModel> _attendanceMap = {};

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
      // Statistics and attendance will be fetched in ScheduleBloc listener
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
                              InkWell(
                                onTap: () => context.push('/notifications'),
                                child: Stack(
                                  children: [
                                    const Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    // TODO: Show dot only if unread
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

                        BlocListener<AttendanceBloc, AttendanceState>(
                          listener: (context, state) {
                            if (state is AttendanceDashboardLoaded) {
                              setState(() {
                                _attendanceMap = state.attendanceMap;
                              });
                            } else if (state is AttendanceScheduleMapLoaded) {
                              setState(() {
                                _attendanceMap = state.attendanceMap;
                              });
                            } else if (state is AttendanceSuccess) {
                              setState(() {
                                final att = state.attendance;
                                if (att.scheduleId != null) {
                                  _attendanceMap[att.scheduleId!] = att;
                                }
                              });
                            }
                          },
                          child: BlocBuilder<ScheduleBloc, ScheduleState>(
                            builder: (context, scheduleState) {
                              // Resolve attendance map reactively
                              final attendanceState = context
                                  .watch<AttendanceBloc>()
                                  .state;
                              Map<String, AttendanceModel> attendanceMap =
                                  _attendanceMap;
                              if (attendanceState
                                  is AttendanceDashboardLoaded) {
                                attendanceMap = attendanceState.attendanceMap;
                              } else if (attendanceState
                                  is AttendanceScheduleMapLoaded) {
                                attendanceMap = attendanceState.attendanceMap;
                              }

                              String timeText = '-';
                              String statusText = 'Tidak Ada Jadwal';
                              Color statusColor = Colors.grey;

                              if (scheduleState is ScheduleLoaded) {
                                final now = DateTime.now();
                                final todayName = DateFormat(
                                  'EEEE',
                                  'id_ID',
                                ).format(now).toLowerCase();

                                // Get Today's Schedules
                                final todaySchedules = scheduleState.schedules
                                    .where(
                                      (s) => s.day.toLowerCase() == todayName,
                                    )
                                    .toList();

                                // Sort by start time
                                todaySchedules.sort(
                                  (a, b) =>
                                      (a.startTime).compareTo(b.startTime),
                                );

                                if (todaySchedules.isNotEmpty) {
                                  // Use resolved attendanceMap

                                  // Priority 1: Check for Strict Ongoing (Checked In AND Not Checked Out)
                                  ScheduleModel? strictOngoing;
                                  try {
                                    strictOngoing = todaySchedules.firstWhere((
                                      s,
                                    ) {
                                      if (!attendanceMap.containsKey(s.id))
                                        return false;
                                      final att =
                                          attendanceMap[s.id]
                                              as AttendanceModel;
                                      // Must have checked in, and not checked out
                                      return att.checkIn != null &&
                                          att.checkOut == null;
                                    });
                                  } catch (e) {
                                    strictOngoing = null;
                                  }

                                  if (strictOngoing != null) {
                                    timeText =
                                        '${strictOngoing.startTime} - ${strictOngoing.endTime}';

                                    final att =
                                        attendanceMap[strictOngoing.id]
                                            as AttendanceModel;
                                    final isLate = att.status == 'telat';

                                    statusText = isLate
                                        ? 'Sedang Mengajar (Terlambat)'
                                        : 'Sedang Mengajar';
                                    statusColor = isLate
                                        ? Colors.orange
                                        : Colors.blue;
                                  } else {
                                    // Priority 2: Check for ANY schedule that has an attendance row without check-in/out (Alpha/Izin/Sakit)
                                    // We only show this if it's the "current" relevant one or if we want to show it as status.
                                    // Let's find the first schedule that is NOT "Done" (Checked Out).
                                    // If it has status Alpha/Izin, we show that.
                                    // If it has no status, we show "Upcoming/Late".

                                    ScheduleModel? activeDisplaySchedule;

                                    // Find first schedule that is NOT fully completed (checked out)
                                    // But wait, Alpha/Izin are also "completed" in a sense.
                                    // Let's find the first schedule where we haven't "finished" it.
                                    // Actually, if I was Alpha at 7am, and it's 10am now, I don't want to see "Alpha" for the 7am class forever.
                                    // I want to see the 10am class.

                                    // So, look for the first schedule that is either:
                                    // 1. In the future
                                    // 2. Currently happening
                                    // 3. Or, if all are past, maybe the last status? (Usually 'All Done')

                                    final now = DateTime.now();
                                    final currentTimeVal =
                                        now.hour * 60 + now.minute;

                                    // Helper to parse time string "HH:mm" to minutes
                                    int toMinutes(String t) {
                                      final p = t
                                          .split(':')
                                          .map(int.parse)
                                          .toList();
                                      return p[0] * 60 + p[1];
                                    }

                                    // Find the "Current or Next" schedule
                                    try {
                                      activeDisplaySchedule = todaySchedules.firstWhere((
                                        s,
                                      ) {
                                        final endMin = toMinutes(s.endTime);
                                        // Keep this schedule if it's not "long past".
                                        // Or simpler: Find first schedule that we haven't "passed" yet OR is the current one.
                                        // If we have an attendance record (even Alpha), is it "passed"?
                                        // Usually yes.

                                        // BUT user specifically asked: "ketika dia sudah memiliki row attendance... status di time card juga mengikuti".
                                        // This implies they want to see "Alpha" if that is the status of the *current* slot.

                                        // So:
                                        final startMin = toMinutes(s.startTime);

                                        // If we are currently WITHIN this schedule's timeframe
                                        if (currentTimeVal >= startMin &&
                                            currentTimeVal <= endMin) {
                                          return true;
                                        }

                                        // If this schedule is in the FUTURE
                                        if (currentTimeVal < startMin) {
                                          return true;
                                        }

                                        // If we are PAST this schedule (currentTime > endMin)
                                        // We normally skip it.
                                        // UNLESS it's the last one? No.

                                        // Exception: If we have NOT checked out (already handled by strictOngoing)

                                        return false;
                                      });
                                    } catch (e) {
                                      activeDisplaySchedule = null;
                                    }

                                    if (activeDisplaySchedule != null) {
                                      timeText =
                                          '${activeDisplaySchedule.startTime} - ${activeDisplaySchedule.endTime}';

                                      // Check if we have attendance data for this active schedule
                                      if (attendanceMap.containsKey(
                                        activeDisplaySchedule.id,
                                      )) {
                                        final att =
                                            attendanceMap[activeDisplaySchedule
                                                    .id]
                                                as AttendanceModel;

                                        // Handle statuses like Alpha, Izin, Sakit
                                        // Case: CheckIn/Out null, but status exists
                                        String statusLabel = att.status;
                                        if (statusLabel == 'alpha')
                                          statusLabel = 'Tidak Hadir (Alpha)';
                                        else if (statusLabel == 'izin')
                                          statusLabel = 'Izin';
                                        else if (statusLabel == 'sakit')
                                          statusLabel = 'Sakit';
                                        else if (statusLabel.isNotEmpty)
                                          statusLabel =
                                              '${statusLabel[0].toUpperCase()}${statusLabel.substring(1)}';

                                        statusText = statusLabel;

                                        if (att.status == 'alpha')
                                          statusColor = Colors.red;
                                        else if (att.status == 'izin' ||
                                            att.status == 'sakit')
                                          statusColor = Colors.blue;
                                        else if (att.status == 'hadir')
                                          statusColor = Colors
                                              .green; // Rare here if strictOngoing failed (maybe checked out?)
                                        // If checked out (finished), maybe show "Selesai" for this specific class?
                                        // If checked out:
                                        if (att.checkOut != null) {
                                          statusText = 'Selesai';
                                          statusColor = Colors.green;
                                        }
                                      } else {
                                        // No attendance data -> Logic for Late / Enter / Upcoming
                                        final startParts = activeDisplaySchedule
                                            .startTime
                                            .split(':')
                                            .map(int.parse)
                                            .toList();
                                        final scheduleStart = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          startParts[0],
                                          startParts[1],
                                        );

                                        if (now
                                                .difference(scheduleStart)
                                                .inMinutes >
                                            15) {
                                          statusText = 'Terlambat';
                                          statusColor = Colors.orange;
                                        } else if (now.isAfter(scheduleStart)) {
                                          statusText = 'Segera Masuk';
                                          statusColor = Colors.orange.shade700;
                                        } else {
                                          statusText = 'Menunggu Jadwal';
                                          statusColor = Colors.grey;
                                        }
                                      }
                                    } else {
                                      // No active or future schedules found -> All Done
                                      timeText = 'Selesai';
                                      statusText = 'Semua Tuntas';
                                      statusColor = Colors.green;
                                    }
                                  }
                                }
                              }

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                      Text(
                                        timeText,
                                        style: const TextStyle(
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
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Kelas Saat Ini Section Removed as per request (Unified into Weekly Schedule)

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
                                  AttendanceFetchDashboardData(
                                    teacherId: userState.teacher.id,
                                    scheduleIds: scheduleIds,
                                    weekStart: _selectedWeekStart,
                                    weekEnd: _selectedWeekEnd,
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
                                  } else if (attendanceState
                                      is AttendanceDashboardLoaded) {
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

                                      final scheduleDate = _getScheduleDate(
                                        _selectedWeekStart,
                                        schedule.day,
                                      );
                                      // final scheduleEndTime = _parseTime(
                                      //   schedule.endTime,
                                      //   scheduleDate,
                                      // );
                                      final endOfDay = DateTime(
                                        scheduleDate.year,
                                        scheduleDate.month,
                                        scheduleDate.day,
                                        23,
                                        59,
                                        59,
                                      );
                                      final now = DateTime.now();

                                      if (attendance == null) {
                                        if (now.isAfter(endOfDay)) {
                                          // Past Day + No Attendance = Alpha
                                          statusLabel = 'Tidak Hadir (Alpha)';
                                          statusColor = const Color(
                                            0xFFEF4444,
                                          ); // Red
                                          actionButton = null;
                                        } else {
                                          // Same Day or Future + No Attendance = Waiting
                                          statusLabel = 'Menunggu';
                                          statusColor = Colors.grey;
                                          actionButton = ElevatedButton(
                                            onPressed: () async {
                                              await context.push(
                                                '/teaching',
                                                extra: {'schedule': schedule},
                                              );
                                              if (context.mounted) {
                                                final userState = context
                                                    .read<UserBloc>()
                                                    .state;
                                                if (userState is UserLoaded) {
                                                  context
                                                      .read<ScheduleBloc>()
                                                      .add(
                                                        ScheduleFetch(
                                                          teacherId: userState
                                                              .teacher
                                                              .id,
                                                        ),
                                                      );
                                                  final scheduleState = context
                                                      .read<ScheduleBloc>()
                                                      .state;
                                                  List<String> scheduleIds = [];
                                                  if (scheduleState
                                                      is ScheduleLoaded) {
                                                    scheduleIds = scheduleState
                                                        .schedules
                                                        .map((e) => e.id)
                                                        .toList();
                                                  }

                                                  context.read<AttendanceBloc>().add(
                                                    AttendanceFetchDashboardData(
                                                      teacherId:
                                                          userState.teacher.id,
                                                      scheduleIds: scheduleIds,
                                                      weekStart:
                                                          _selectedWeekStart,
                                                      weekEnd: _selectedWeekEnd,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF1E3A8A,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                        }
                                      } else {
                                        // Has attendance data
                                        final status = attendance.status
                                            .toLowerCase();

                                        if (attendance.checkIn != null &&
                                            attendance.checkOut == null) {
                                          // Checked in, not checked out
                                          statusLabel = (status == 'telat')
                                              ? 'Sedang Mengajar (Terlambat)'
                                              : 'Sedang Mengajar';
                                          statusColor = Colors.orange;
                                          actionButton = ElevatedButton(
                                            onPressed: () async {
                                              await context.push(
                                                '/teaching',
                                                extra: {
                                                  'schedule': schedule,
                                                  'attendance': attendance,
                                                },
                                              );
                                              if (context.mounted) {
                                                final userState = context
                                                    .read<UserBloc>()
                                                    .state;
                                                if (userState is UserLoaded) {
                                                  context
                                                      .read<ScheduleBloc>()
                                                      .add(
                                                        ScheduleFetch(
                                                          teacherId: userState
                                                              .teacher
                                                              .id,
                                                        ),
                                                      );
                                                  final scheduleState = context
                                                      .read<ScheduleBloc>()
                                                      .state;
                                                  List<String> scheduleIds = [];
                                                  if (scheduleState
                                                      is ScheduleLoaded) {
                                                    scheduleIds = scheduleState
                                                        .schedules
                                                        .map((e) => e.id)
                                                        .toList();
                                                  }

                                                  context.read<AttendanceBloc>().add(
                                                    AttendanceFetchDashboardData(
                                                      teacherId:
                                                          userState.teacher.id,
                                                      scheduleIds: scheduleIds,
                                                      weekStart:
                                                          _selectedWeekStart,
                                                      weekEnd: _selectedWeekEnd,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                          // Completed / Others
                                          String checkInTimeStr = '-';
                                          String checkOutTimeStr = '-';

                                          if (attendance.checkIn != null) {
                                            checkInTimeStr = DateFormat('HH:mm')
                                                .format(
                                                  DateTime.parse(
                                                    attendance.checkIn!,
                                                  ),
                                                );
                                          }

                                          if (attendance.checkOut != null) {
                                            checkOutTimeStr =
                                                DateFormat('HH:mm').format(
                                                  DateTime.parse(
                                                    attendance.checkOut!,
                                                  ),
                                                );
                                          }

                                          switch (status) {
                                            case 'hadir':
                                              statusLabel = 'Hadir';
                                              statusColor = const Color(
                                                0xFF10B981,
                                              ); // Green
                                              break;
                                            case 'telat':
                                              statusLabel = 'Terlambat';
                                              statusColor = Colors.orange;
                                              break;
                                            case 'izin':
                                              statusLabel = 'Izin';
                                              statusColor = Colors.blue;
                                              break;
                                            case 'sakit':
                                              statusLabel = 'Sakit';
                                              statusColor = Colors.blue;
                                              break;
                                            case 'alpha':
                                              statusLabel =
                                                  'Tidak Hadir (Alpha)';
                                              statusColor = const Color(
                                                0xFFEF4444,
                                              ); // Red
                                              break;
                                            default:
                                              // Capitalize first letter
                                              statusLabel = status.isEmpty
                                                  ? 'Hadir'
                                                  : '${status[0].toUpperCase()}${status.substring(1)}';
                                              statusColor = Colors.grey;
                                          }

                                          // Append time if relevant (for hadir/telat)
                                          if (status == 'hadir' ||
                                              status == 'telat') {
                                            statusLabel +=
                                                ' ($checkInTimeStr - $checkOutTimeStr)';
                                          }

                                          actionButton =
                                              null; // No button for completed
                                        }
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
                                                    Wrap(
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      spacing: 8,
                                                      runSpacing: 4,
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
                                                            null)
                                                          actionButton,
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
                          } else if (state is AttendanceDashboardLoaded) {
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

  DateTime _getScheduleDate(DateTime weekStart, String dayName) {
    final days = [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu',
    ];
    final dayIndex = days.indexOf(dayName.toLowerCase());
    if (dayIndex == -1) return weekStart;
    return weekStart.add(Duration(days: dayIndex));
  }
}
