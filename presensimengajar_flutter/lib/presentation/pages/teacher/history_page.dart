import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/attendance/attendance_event.dart';
import '../../blocs/attendance/attendance_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';
import '../../blocs/academic_period/academic_period_bloc.dart';
import '../../blocs/academic_period/academic_period_event.dart';
import '../../blocs/academic_period/academic_period_state.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/academic_period_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    context.read<AcademicPeriodBloc>().add(FetchAcademicPeriods());
    // Attendance fetch will be triggered by AcademicPeriodLoaded listener or manual call
    _fetchHistory();
  }

  void _fetchHistory() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endDate = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
      );

      context.read<AttendanceBloc>().add(
        AttendanceFetchHistory(
          teacherId: userState.teacher.id,
          startDate: startDate,
          endDate: endDate,
        ),
      );
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
    _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          _fetchHistory();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildAcademicPeriodWarning(),
              Expanded(
                child: BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, state) {
                    if (state is AttendanceLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AttendanceHistoryLoaded) {
                      return ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          _buildStatsGrid(state.history),
                          const SizedBox(height: 24),
                          _buildHistoryList(state.history),
                        ],
                      );
                    } else if (state is AttendanceError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              _buildMonthSelector(),
            ],
          ),
          const SizedBox(height: 16),
          _buildAcademicPeriodDropdown(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _changeMonth(-1),
            child: const Icon(Icons.chevron_left, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _changeMonth(1),
            child: const Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicPeriodDropdown() {
    return BlocBuilder<AcademicPeriodBloc, AcademicPeriodState>(
      builder: (context, state) {
        if (state is AcademicPeriodLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AcademicPeriodModel>(
                value: state.selectedPeriod,
                isExpanded: true,
                itemHeight: null,
                hint: const Text('Pilih Kurikulum'),
                items: state.periods.map((period) {
                  final startDate = DateFormat(
                    'd MMM yyyy',
                    'id_ID',
                  ).format(DateTime.parse(period.startDate));
                  final endDate = DateFormat(
                    'd MMM yyyy',
                    'id_ID',
                  ).format(DateTime.parse(period.endDate));

                  return DropdownMenuItem(
                    value: period,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                period.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (period.isActive) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '$startDate - $endDate',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<AcademicPeriodBloc>().add(
                      SelectAcademicPeriod(val),
                    );
                  }
                },
              ),
            ),
          );
        }
        return const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildAcademicPeriodWarning() {
    return BlocBuilder<AcademicPeriodBloc, AcademicPeriodState>(
      builder: (context, state) {
        if (state is AcademicPeriodLoaded && state.selectedPeriod != null) {
          // Check if selected MONTH is fully outside active period?
          // Or just check if selected month overlaps with period?
          // The requirement says: "Diluar jadwal academic_periods yang aktif, maka tampilkan pesan..."
          // Assuming we check if the _selectedMonth is within the period start/end range.

          final start = DateTime.parse(state.selectedPeriod!.startDate);
          final end = DateTime.parse(state.selectedPeriod!.endDate);

          // Check intersection of selected month with period
          final selectedMonthStart = DateTime(
            _selectedMonth.year,
            _selectedMonth.month,
            1,
          );
          final selectedMonthEnd = DateTime(
            _selectedMonth.year,
            _selectedMonth.month + 1,
            0,
          );

          bool isOverlapping =
              !(selectedMonthEnd.isBefore(start) ||
                  selectedMonthStart.isAfter(end));

          if (!isOverlapping) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Diluar Jadwal Kurikulum Yang Aktif',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsGrid(List<AttendanceModel> history) {
    // Calculate stats
    int hadir = history.where((a) => a.checkIn != null).length;
    int telat = history.where((a) => a.status == 'telat').length;
    int izin = history
        .where((a) => a.status == 'izin' || a.status == 'sakit')
        .length;
    int alpha = history.where((a) => a.status == 'alpha').length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatBox(
          'Hadir',
          hadir.toString(),
          const Color(0xFFE6F4F1),
          const Color(0xFF10B981),
        ),
        _buildStatBox(
          'Telat',
          telat.toString(),
          const Color(0xFFFEF3C7),
          const Color(0xFFF59E0B),
        ),
        _buildStatBox(
          'Izin',
          izin.toString(),
          const Color(0xFFDBEAFE),
          const Color(0xFF3B82F6),
        ),
        _buildStatBox(
          'Alpha',
          alpha.toString(),
          const Color(0xFFFEE2E2),
          const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<AttendanceModel> history) {
    if (history.isEmpty) {
      return const Center(child: Text('Belum ada riwayat'));
    }

    return Column(
      children: history.map((attendance) {
        // Mock data logic for display for now until we have full attendance details

        Color statusColor = const Color(0xFF10B981); // Success
        Color bgColor = const Color(0xFFECFDF5);
        String statusText = 'Hadir Tepat Waktu';
        String timeText = '07:00 - 14:00'; // Mock

        if (attendance.checkIn != null) {
          final checkIn = DateTime.parse(attendance.checkIn!);
          timeText = DateFormat('HH:mm').format(checkIn);
          if (attendance.checkOut != null) {
            timeText +=
                ' - ${DateFormat('HH:mm').format(DateTime.parse(attendance.checkOut!))}';
          }
        }

        // Status logic
        if (attendance.status == 'telat') {
          statusColor = const Color(0xFFF59E0B);
          bgColor = const Color(0xFFFFFBEB);
          statusText = 'Terlambat';
        } else if (attendance.status == 'izin' ||
            attendance.status == 'sakit') {
          statusColor = const Color(0xFF3B82F6);
          bgColor = const Color(0xFFEFF6FF);
          statusText = 'Izin';
        } else if (attendance.status == 'alpha') {
          statusColor = const Color(0xFFEF4444);
          bgColor = const Color(0xFFFEE2E2);
          statusText = 'Alpha';
        }

        final schedule = attendance.schedule;
        final subjectName =
            schedule?.subject?.getStringValue('name') ?? 'Mata Pelajaran';
        final className = schedule?.classInfo?.getStringValue('name') ?? '-';

        final date = DateTime.parse(attendance.date);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: statusColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd').format(date),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEE', 'id_ID').format(date).toUpperCase(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$subjectName - $className',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeText,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        );
      }).toList(),
    );
  }
}
