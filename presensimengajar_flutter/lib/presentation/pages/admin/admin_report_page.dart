import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../blocs/admin_report/admin_report_bloc.dart';
import '../../blocs/admin_report/admin_report_event.dart';
import '../../blocs/admin_report/admin_report_state.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fetchReport();
  }

  void _fetchReport() {
    context.read<AdminReportBloc>().add(
          AdminReportFetch(
            month: _selectedDate.month,
            year: _selectedDate.year,
          ),
        );
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + offset,
      );
    });
    _fetchReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMonthSelector(),
            Expanded(child: _buildReportContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Panel Admin',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Laporan Presensi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text('AD', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return BlocBuilder<AdminReportBloc, AdminReportState>(
      builder: (context, state) {
        if (state is AdminReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminReportError) {
          return Center(child: Text(state.message));
        }

        if (state is AdminReportLoaded) {
          if (state.reportData.isEmpty) {
            return const Center(child: Text('Tidak ada data laporan'));
          }
          return _buildTable(state.reportData);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor:
              WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.1)),
          columns: const [
            DataColumn(label: Text('Nama Guru')),
            DataColumn(label: Text('Hadir')),
            DataColumn(label: Text('Telat')),
            DataColumn(label: Text('Izin/Sakit')),
            DataColumn(label: Text('Alpha')),
          ],
          rows: data.map((row) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        row['teacherName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        row['teacherNip'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    row['present'].toString(),
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                DataCell(
                  Text(
                    row['late'].toString(),
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
                DataCell(
                  Text(
                    row['permit'].toString(),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                DataCell(
                  Text(
                    row['alpha'].toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
