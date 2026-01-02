import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/theme.dart';
import '../../../data/models/teacher_model.dart';
import '../../blocs/admin_teacher/admin_teacher_bloc.dart';
import '../../blocs/admin_teacher/admin_teacher_event.dart';
import '../../blocs/admin_teacher/admin_teacher_state.dart';
import '../../widgets/stat_card_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class TeacherManagementPage extends StatefulWidget {
  const TeacherManagementPage({super.key});

  @override
  State<TeacherManagementPage> createState() => _TeacherManagementPageState();
}

class _TeacherManagementPageState extends State<TeacherManagementPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<AdminTeacherBloc>().add(const AdminTeacherFetchList());
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    // No network call here, only local filter on submit or manual trigger?
    // Requirement: "menunggu pengguna tekan enter baru proses pencarian"
    // AND "langsung pencarian di lokal saja"
    // So we can do local search immediately OR on Enter?
    // "buat agar menunggu pengguna tekan enter" implies explicit action.
    // However, fast local search is usually real-time.
    // But since User explicitly asked for "Enter", I will respect that.
    // Wait, "pencarian di lokal saja" suggests performance is fine.
    // But "menunggu enter" suggests they don't want it jumping around.
    // I will enforce "Enter" key trigger but it will be a local filter operation.
  }

  void _onSubmitSearch(String value) {
    context.read<AdminTeacherBloc>().add(
      AdminTeacherFilter(query: value, status: _statusFilter),
    );
  }

  void _onFilterChanged(String status) {
    setState(() {
      _statusFilter = status;
    });
    context.read<AdminTeacherBloc>().add(
      AdminTeacherFilter(query: _searchQuery, status: _statusFilter),
    );
  }

  void _showTeacherForm(BuildContext context, {TeacherModel? teacher}) {
    context.push('/teacher-form', extra: teacher);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminTeacherBloc, AdminTeacherState>(
      listener: (context, state) {
        if (state is AdminTeacherOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AdminTeacherExportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Buka',
                textColor: Colors.white,
                onPressed: () {
                  OpenFile.open(state.path);
                },
              ),
            ),
          );
          // Also show a bottom sheet or another option to share?
          // User asked for "pilihan share / open". A SnackBar usually has one action.
          // Let's show a Dialog or ModalBottomSheet for better UX if both distinct options are needed.
          // Or just Open in SnackBar, and rely on OpenFile's capability?
          // Actually, let's use a Modal here to be explicit as requested.

          showModalBottomSheet(
            context: context,
            builder: (ctx) => Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ekspor Berhasil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('File disimpan di: ${state.path}'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.pop();
                            OpenFile.open(state.path);
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Buka File'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.pop();
                            Share.shareXFiles([
                              XFile(state.path),
                            ], text: 'Data Guru');
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Bagikan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (state is AdminTeacherError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // Content
        Widget content;
        if (state is AdminTeacherLoading) {
          content = const Center(child: CircularProgressIndicator());
        } else if (state is AdminTeacherLoaded) {
          content = RefreshIndicator(
            onRefresh: () async {
              context.read<AdminTeacherBloc>().add(
                const AdminTeacherFetchList(),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Search & Filter
                  _buildSearchAndFilter(),
                  const SizedBox(height: 20),
                  // Stats
                  _buildStats(state),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<AdminTeacherBloc>().add(
                              AdminTeacherImport(),
                            );
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Impor CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[50],
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<AdminTeacherBloc>().add(
                              AdminTeacherExport(),
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Ekspor CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[50],
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showTeacherForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Guru Baru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // List
                  _buildTeacherList(state),
                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
          );
        } else {
          content = const Center(child: Text('Memuat data...'));
        }

        return Column(
          children: [
            // Custom Header
            Container(
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
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Manajemen Guru',
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
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          onChanged: _onSearchChanged,
          onSubmitted: _onSubmitSearch,
          decoration: InputDecoration(
            hintText: 'Cari nama atau NIP...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFilterButton('Semua', 'all'),
            const SizedBox(width: 8),
            _buildFilterButton('Aktif', 'active'),
            const SizedBox(width: 8),
            _buildFilterButton('Non-Aktif', 'inactive'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _statusFilter == value;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _onFilterChanged(value),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.grey[700],
          elevation: 0,
          side: isSelected ? null : BorderSide(color: Colors.grey[300]!),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildStats(AdminTeacherLoaded state) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.7, // Taller cards
      children: [
        StatCardWidget(
          value: state.total.toString(),
          label: 'Total',
          color: AppTheme.statBlue,
        ),
        StatCardWidget(
          value: state.active.toString(),
          label: 'Aktif',
          color: AppTheme.statGreen,
        ),
        StatCardWidget(
          value: state.newTeachers.toString(),
          label: 'Baru',
          color: AppTheme.statYellow,
        ),
        StatCardWidget(
          value: state.inactive.toString(),
          label: 'Non-Aktif',
          color: AppTheme.statRed,
        ),
      ],
    );
  }

  Widget _buildTeacherList(AdminTeacherLoaded state) {
    if (state.teachers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.person_off, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data guru ditemukan',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.teachers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final teacher = state.teachers[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: teacher.status == 'inactive'
                ? Border(left: BorderSide(color: Colors.red[300]!, width: 4))
                : null,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: teacher.photo.isNotEmpty
                    ? NetworkImage(
                        teacher.getPhotoUrl(
                          dotenv.env['POCKETBASE_URL'] ??
                              'http://127.0.0.1:8090',
                        ),
                      ) // TODO: Use proper Base URL from Env
                    : null,
                child: teacher.photo.isEmpty
                    ? Text(
                        teacher.name.substring(0, 1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'NIP: ${teacher.nip}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher.subjectName ?? teacher.subjectId ?? 'Guru Umum',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildBadge(
                          teacher.status == 'active' ? 'Aktif' : 'Non-Aktif',
                          teacher.status == 'active'
                              ? Colors.green
                              : Colors.red,
                        ),
                        _buildBadge(
                          teacher.attendanceCategory == 'tetap'
                              ? 'Tetap'
                              : 'Jadwal',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () =>
                        _showTeacherForm(context, teacher: teacher),
                    icon: const Icon(Icons.edit, color: Colors.amber),
                  ),
                  IconButton(
                    onPressed: () {
                      context.push('/admin-schedule', extra: teacher);
                    },
                    icon: const Icon(Icons.calendar_month, color: Colors.blue),
                    tooltip: 'Atur Jadwal',
                  ),
                  IconButton(
                    onPressed: () {
                      // Confirm Delete
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Guru'),
                          content: Text(
                            'Apakah anda yakin ingin menghapus data guru ${teacher.name}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<AdminTeacherBloc>().add(
                                  AdminTeacherDelete(teacher.id),
                                );
                                context.pop();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
