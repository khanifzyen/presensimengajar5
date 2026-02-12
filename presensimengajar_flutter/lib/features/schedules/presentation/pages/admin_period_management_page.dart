import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:presensimengajar_flutter/core/theme/app_theme.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/data/models/master_models.dart';
import 'package:presensimengajar_flutter/features/schedules/presentation/blocs/academic_period/academic_period_bloc.dart';
import 'package:presensimengajar_flutter/features/schedules/presentation/blocs/academic_period/academic_period_event.dart';
import 'package:presensimengajar_flutter/features/schedules/presentation/blocs/academic_period/academic_period_state.dart';

class AdminPeriodManagementPage extends StatefulWidget {
  const AdminPeriodManagementPage({super.key});

  @override
  State<AdminPeriodManagementPage> createState() =>
      _AdminPeriodManagementPageState();
}

class _AdminPeriodManagementPageState extends State<AdminPeriodManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<AcademicPeriodBloc>().add(FetchAcademicPeriods());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcademicPeriodBloc, AcademicPeriodState>(
      listener: (context, state) {
        if (state is AcademicPeriodSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AcademicPeriodError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showFormDialog(context),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: BlocBuilder<AcademicPeriodBloc, AcademicPeriodState>(
                  builder: (context, state) {
                    if (state is AcademicPeriodLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AcademicPeriodLoaded) {
                      if (state.periods.isEmpty) {
                        return const Center(
                          child: Text('Belum ada data periode akademik'),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.periods.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildPeriodItem(
                            context,
                            state.periods[index],
                          );
                        },
                      );
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            color: Colors.black87,
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manajemen Kurikulum',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kelola tahun ajaran dan semester',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodItem(BuildContext context, AcademicPeriodModel period) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: period.isActive
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: period.isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              FontAwesomeIcons.calendar,
              color: period.isActive ? AppTheme.primaryColor : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      period.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (period.isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Aktif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${period.startDate} - ${period.endDate}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showFormDialog(context, period: period);
              } else if (value == 'delete') {
                _showDeleteDialog(context, period);
              } else if (value == 'activate') {
                context.read<AcademicPeriodBloc>().add(
                  SetActivePeriod(period.id),
                );
              }
            },
            itemBuilder: (context) => [
              if (!period.isActive)
                const PopupMenuItem(
                  value: 'activate',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Set Aktif'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              if (!period.isActive) // Prevent deleting active period
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AcademicPeriodModel period) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Periode?'),
        content: Text(
          'Anda yakin ingin menghapus periode "${period.name}"? Data jadwal yang terkait mungkin akan terpengaruh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AcademicPeriodBloc>().add(
                DeleteAcademicPeriod(period.id),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, {AcademicPeriodModel? period}) {
    final nameController = TextEditingController(text: period?.name ?? '');
    final startDateController = TextEditingController(
      text: period?.startDate ?? '',
    );
    final endDateController = TextEditingController(
      text: period?.endDate ?? '',
    );
    bool isActive = period?.isActive ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(period == null ? 'Tambah Periode' : 'Edit Periode'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Periode (Contoh: 2024/2025 Ganjil)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Mulai (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    startDateController.text = date.toIso8601String().split(
                      'T',
                    )[0];
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Selesai (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    endDateController.text = date.toIso8601String().split(
                      'T',
                    )[0];
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  startDateController.text.isEmpty ||
                  endDateController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mohon lengkapi data')),
                );
                return;
              }

              final data = {
                'name': nameController.text,
                'start_date': startDateController.text,
                'end_date': endDateController.text,
                'is_active': isActive,
              };

              if (period == null) {
                context.read<AcademicPeriodBloc>().add(
                  CreateAcademicPeriod(data),
                );
              } else {
                context.read<AcademicPeriodBloc>().add(
                  UpdateAcademicPeriod(period.id, data),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
