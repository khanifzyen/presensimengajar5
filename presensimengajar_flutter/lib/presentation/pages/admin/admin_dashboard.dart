import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/admin/admin_bloc.dart';
import '../../blocs/admin/admin_event.dart';
import '../../blocs/admin/admin_state.dart';
import '../../widgets/stat_card_widget.dart';
import '../../widgets/teacher_monitoring_item.dart';
import '../../../core/theme.dart';
import '../../../data/models/teacher_model.dart';
import 'teacher_management_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load dashboard data when page loads
    context.read<AdminBloc>().add(const AdminLoadDashboard());
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different pages based on index
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        // Navigate to teacher management (placeholder for now)
        break;
      case 2:
        // Navigate to leave approval (placeholder for now)
        break;
      case 3:
        // Navigate to reports (placeholder for now)
        break;
      case 4:
        // Navigate to settings (placeholder for now)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return const TeacherManagementPage();
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildDashboardView() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminBloc>().add(const AdminRefreshData());
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is AdminLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminBloc>().add(const AdminRefreshData());
              // Wait a bit for the refresh to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context),

                  const SizedBox(height: 20),

                  // Attendance Statistics Section
                  _buildAttendanceSection(context, state),

                  const SizedBox(height: 20),

                  // Teacher Category Statistics
                  _buildCategorySection(context, state),

                  const SizedBox(height: 20),

                  // Leave Request Alert
                  _buildLeaveRequestAlert(context, state),

                  const SizedBox(height: 20),

                  // Real-time Monitoring
                  _buildMonitoringSection(context, state),

                  const SizedBox(height: 80), // Bottom padding for nav bar
                ],
              ),
            ),
          );
        }

        // Initial state
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Panel Admin',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'SMP Negeri 1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Text(
              'AD',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(BuildContext context, AdminLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.getDateTitle(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    state.getDateString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  // Left arrow (go backward to older date) - positioned on the left
                  IconButton(
                    onPressed: () {
                      context.read<AdminBloc>().add(
                        AdminChangeDateOffset(state.dateOffset + 1),
                      );
                    },
                    icon: const Icon(Icons.chevron_left),
                    color: AppTheme.primaryColor,
                  ),
                  // Right arrow (go forward to more recent date) - positioned on the right
                  IconButton(
                    onPressed: state.dateOffset > 0
                        ? () {
                            context.read<AdminBloc>().add(
                              AdminChangeDateOffset(state.dateOffset - 1),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    color: AppTheme.primaryColor,
                    disabledColor: Colors.grey[300],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats cards
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75,
            children: [
              StatCardWidget(
                value: state.attendanceStats['total'].toString(),
                label: 'Total Guru',
                color: AppTheme.statBlue,
              ),
              StatCardWidget(
                value: state.attendanceStats['present'].toString(),
                label: 'Hadir',
                color: AppTheme.statGreen,
              ),
              StatCardWidget(
                value: state.attendanceStats['leave'].toString(),
                label: 'Izin',
                color: AppTheme.statYellow,
              ),
              StatCardWidget(
                value: state.attendanceStats['absent'].toString(),
                label: 'Belum',
                color: AppTheme.statRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, AdminLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Kategori Guru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75,
            children: [
              StatCardWidget(
                value: state.categoryStats['tetap'].toString(),
                label: 'Guru Tetap',
                color: AppTheme.statBlue,
              ),
              StatCardWidget(
                value: state.categoryStats['jadwal'].toString(),
                label: 'Guru Jadwal',
                color: AppTheme.statGreen,
              ),
              StatCardWidget(
                value: state.categoryStats['presensi_kantor'].toString(),
                label: 'Presensi Kantor',
                color: AppTheme.statPurple,
              ),
              StatCardWidget(
                value: state.categoryStats['presensi_mengajar'].toString(),
                label: 'Presensi Mengajar',
                color: AppTheme.statOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestAlert(BuildContext context, AdminLoaded state) {
    final pendingCount = state.pendingLeaveRequests.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: pendingCount > 0
              ? AppTheme.statYellow.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: pendingCount > 0
                ? AppTheme.statYellow.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              pendingCount > 0
                  ? Icons.notifications_active
                  : Icons.check_circle,
              color: pendingCount > 0
                  ? AppTheme.statYellow
                  : AppTheme.statGreen,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pendingCount > 0
                        ? '$pendingCount Pengajuan Izin Baru'
                        : 'Tidak Ada Pengajuan Izin Baru',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (pendingCount > 0)
                    Text(
                      'Menunggu persetujuan Anda.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            if (pendingCount > 0)
              ElevatedButton(
                onPressed: () {
                  // Navigate to approval page (placeholder)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigasi ke halaman approval izin'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                ),
                child: const Text('Lihat', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringSection(BuildContext context, AdminLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monitoring Real-time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (state.realtimeMonitoring.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data monitoring',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.realtimeMonitoring.length,
              itemBuilder: (context, index) {
                final item = state.realtimeMonitoring[index];
                return TeacherMonitoringItem(
                  teacher: item['teacher'] as TeacherModel,
                  subjectInfo: item['subjectInfo'] as String,
                  categoryBadge: item['categoryBadge'] as String,
                  statusText: item['statusText'] as String,
                  statusColor: item['statusColor'] as String,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dash'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Guru'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Izin',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Rekap'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Set'),
        ],
      ),
    );
  }
}
