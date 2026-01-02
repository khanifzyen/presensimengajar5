import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/teacher_model.dart';
import '../../blocs/admin_schedule/admin_schedule_bloc.dart';
import '../../blocs/admin_schedule/admin_schedule_event.dart';
import '../../blocs/admin_schedule/admin_schedule_state.dart';
import '../../../core/theme.dart';

class AdminSchedulePage extends StatefulWidget {
  final TeacherModel teacher;

  const AdminSchedulePage({super.key, required this.teacher});

  @override
  State<AdminSchedulePage> createState() => _AdminSchedulePageState();
}

class _AdminSchedulePageState extends State<AdminSchedulePage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminScheduleBloc>().add(
          AdminScheduleFetch(widget.teacher.id),
        );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminScheduleBloc>().add(
                    AdminScheduleDelete(id, widget.teacher.id),
                  );
              ctx.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminScheduleBloc, AdminScheduleState>(
      listener: (context, state) {
        if (state is AdminScheduleOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AdminScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Jadwal ${widget.teacher.name}'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push(
              '/admin-schedule-form',
              extra: {'teacher': widget.teacher},
            ).then((_) {
              if (mounted) {
                context.read<AdminScheduleBloc>().add(
                      AdminScheduleFetch(widget.teacher.id),
                    );
              }
            });
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: BlocBuilder<AdminScheduleBloc, AdminScheduleState>(
          builder: (context, state) {
            if (state is AdminScheduleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminScheduleLoaded) {
              if (state.schedules.isEmpty) {
                return const Center(child: Text('Belum ada jadwal'));
              }

              // Group by Day
              final schedules = state.schedules;
              schedules.sort((a, b) {
                final dayOrder = {
                  'senin': 1,
                  'selasa': 2,
                  'rabu': 3,
                  'kamis': 4,
                  'jumat': 5,
                  'sabtu': 6,
                  'minggu': 7
                };
                final da = dayOrder[a.day.toLowerCase()] ?? 8;
                final db = dayOrder[b.day.toLowerCase()] ?? 8;
                if (da != db) return da.compareTo(db);
                return a.startTime.compareTo(b.startTime);
              });

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: schedules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = schedules[index];
                  final isDynamic = item.type != 'regular';

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDynamic
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDynamic ? Icons.event_note : Icons.calendar_today,
                          color: isDynamic ? Colors.orange : Colors.blue,
                        ),
                      ),
                      title: Text(
                        item.subject?.getStringValue('name') ?? 'Mapel',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${item.day.toUpperCase()} • ${item.startTime} - ${item.endTime}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Kelas: ${item.classInfo?.getStringValue('name') ?? '-'} • Ruang: ${item.room}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (isDynamic && item.specificDate != null)
                            Text(
                              'Tanggal: ${item.specificDate}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              context.push(
                                '/admin-schedule-form',
                                extra: {
                                  'teacher': widget.teacher,
                                  'schedule': item,
                                },
                              ).then((_) {
                                if (mounted) {
                                  context.read<AdminScheduleBloc>().add(
                                        AdminScheduleFetch(widget.teacher.id),
                                      );
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(item.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
