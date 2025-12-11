import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:intl/intl.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';
import '../../blocs/schedule/schedule_bloc.dart';
import '../../blocs/schedule/schedule_event.dart';
import '../../blocs/schedule/schedule_state.dart';
import 'profile_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  late Timer _timer;
  String _timeString = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _updateTime(),
    );

    // Fetch user profile and schedule on init
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserBloc>().add(UserGetProfile(authState.userId));
      context.read<ScheduleBloc>().add(
        ScheduleFetch(teacherId: authState.userId),
      ); // Assuming teacherId is same as userId for now or handled in repo
    }
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          const Center(child: Text('Jadwal Page Placeholder')),
          const Center(child: Text('Riwayat Page Placeholder')),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendarDays),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.clockRotateLeft),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
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
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Navigate to Scan/Attendance
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(FontAwesomeIcons.camera, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            context.read<UserBloc>().add(UserGetProfile(authState.userId));
            context.read<ScheduleBloc>().add(
              ScheduleFetch(teacherId: authState.userId),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoaded) {
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage: state.teacher.photo.isNotEmpty
                              ? NetworkImage(state.teacher.photo)
                              : null,
                          child: state.teacher.photo.isEmpty
                              ? Text(
                                  state.teacher.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Halo, Selamat Pagi',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              state.teacher.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.bell),
                              onPressed: () {},
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),

              // Time Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _timeString,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'monospace',
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat(
                        'EEEE, d MMMM yyyy',
                        'id_ID',
                      ).format(DateTime.now()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Jam Ajar',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '05:30', // Placeholder
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tepat Waktu', // Placeholder
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Today's Schedule
              const Text(
                'Jadwal Hari Ini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              BlocBuilder<ScheduleBloc, ScheduleState>(
                builder: (context, state) {
                  if (state is ScheduleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ScheduleLoaded) {
                    if (state.schedules.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/no_data.png',
                              width: 200,
                            ),
                            const SizedBox(height: 16),
                            const Text('Belum ada jadwal hari ini'),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = state.schedules[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                FontAwesomeIcons.book,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: Text(
                              schedule.subjectId,
                            ), // Should resolve to subject name
                            subtitle: Text(
                              '${schedule.startTime} - ${schedule.endTime} • ${schedule.classId}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    );
                  } else if (state is ScheduleError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
