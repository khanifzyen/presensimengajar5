import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/attendance/attendance_event.dart';
import '../../blocs/attendance/attendance_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/attendance_model.dart';

class TeachingPage extends StatefulWidget {
  final ScheduleModel schedule;

  const TeachingPage({super.key, required this.schedule});

  @override
  State<TeachingPage> createState() => _TeachingPageState();
}

class _TeachingPageState extends State<TeachingPage> {
  late Timer _timer;
  String _timeString = '';

  @override
  void initState() {
    super.initState();
    _timeString = DateFormat('HH:mm:ss').format(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _updateTime(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _timeString = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get subject and class names safely
    final subjectName =
        widget.schedule.subject?.getStringValue('name') ?? 'Unknown Subject';
    final className =
        widget.schedule.classInfo?.getStringValue('name') ?? 'Unknown Class';

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background color
      appBar: AppBar(
        title: const Text(
          'Mode Mengajar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Presensi berhasil dicatat!')),
            );
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          AttendanceModel? attendance;
          bool isCheckedIn = false;

          if (state is AttendanceScheduleMapLoaded) {
            attendance = state.attendanceMap[widget.schedule.id];
            if (attendance?.checkIn != null && attendance?.checkOut == null) {
              isCheckedIn = true;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                          fontSize: 48,
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
                      Text(
                        subjectName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$className • ${widget.schedule.startTime} - ${widget.schedule.endTime}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isCheckedIn
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCheckedIn ? Icons.check_circle : Icons.pending,
                        color: isCheckedIn ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCheckedIn
                            ? 'Status: SEDANG MENGAJAR'
                            : 'Status: BELUM MENGAJAR',
                        style: TextStyle(
                          color: isCheckedIn ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Slide Action
                if (!isCheckedIn)
                  SlideAction(
                    text: 'Geser untuk Check-In',
                    outerColor: Theme.of(context).primaryColor,
                    innerColor: Colors.white,
                    textColor: Colors.white,
                    onSubmit: () async {
                      final userState = context.read<UserBloc>().state;
                      if (userState is UserLoaded) {
                        context.read<AttendanceBloc>().add(
                          AttendanceCheckIn(
                            teacherId: userState.teacher.id,
                            scheduleId: widget.schedule.id,
                            latitude: 0,
                            longitude: 0,
                            photo: File(''), // TODO: Implement camera
                          ),
                        );
                      }
                      return null;
                    },
                  )
                else
                  SlideAction(
                    text: 'Geser untuk Check-Out',
                    outerColor: Colors.red,
                    innerColor: Colors.white,
                    textColor: Colors.white,
                    onSubmit: () async {
                      final userState = context.read<UserBloc>().state;
                      if (userState is UserLoaded && attendance != null) {
                        context.read<AttendanceBloc>().add(
                          AttendanceCheckOut(
                            attendanceId: attendance.id,
                            latitude: 0,
                            longitude: 0,
                          ),
                        );
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
