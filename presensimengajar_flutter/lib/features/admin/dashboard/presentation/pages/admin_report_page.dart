import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:presensimengajar_flutter/core/theme/app_theme.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/presentation/blocs/admin_report/admin_report_bloc.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/presentation/blocs/admin_report/admin_report_event.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/presentation/blocs/admin_report/admin_report_state.dart';
import '../utils/report_export_service.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  late DateTime _selectedDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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
            _buildFilters(),
            Expanded(child: _buildReportContent()),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'export_pdf',
            onPressed: () => _exportReport('pdf'),
            label: const Text('PDF'),
            icon: const Icon(Icons.picture_as_pdf),
            backgroundColor: Colors.red,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'export_csv',
            onPressed: () => _exportReport('csv'),
            label: const Text('Excel/CSV'),
            icon: const Icon(Icons.table_chart),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport(String type) async {
    final state = context.read<AdminReportBloc>().state;
    if (state is AdminReportLoaded && state.reportData.isNotEmpty) {
      if (type == 'csv') {
        await ReportExportService.exportToCsv(
          state.reportData,
          _selectedDate.month,
          _selectedDate.year,
        );
      } else if (type == 'pdf') {
        await ReportExportService.exportToPdf(
          state.reportData,
          _selectedDate.month,
          _selectedDate.year,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diexport')),
      );
    }
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori Guru',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              value: _selectedCategory,
              items: const [
                DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                DropdownMenuItem(value: 'tetap', child: Text('Guru Tetap')),
                DropdownMenuItem(value: 'jadwal', child: Text('Guru Jadwal')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                _fetchReport();
              },
            ),
          ),
        ],
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

  void _fetchReport() {
    context.read<AdminReportBloc>().add(
      AdminReportFetch(
        month: _selectedDate.month,
        year: _selectedDate.year,
        category: _selectedCategory,
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          headingRowColor: WidgetStateProperty.all(
            AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
          columns: const [
            DataColumn(label: Text('Nama Guru')),
            DataColumn(label: Text('Hadir')),
            DataColumn(label: Text('Telat')),
            DataColumn(label: Text('Izin/Sakit')),
            DataColumn(label: Text('Alpha')),
            DataColumn(label: Text('Total')),
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
                DataCell(
                  Text(
                    row['totalAttendance'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
