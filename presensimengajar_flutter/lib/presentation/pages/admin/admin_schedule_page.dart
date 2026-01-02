import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/teacher_model.dart';
import '../../blocs/admin_schedule/admin_schedule_bloc.dart';
import '../../blocs/admin_schedule/admin_schedule_event.dart';
import '../../blocs/admin_schedule/admin_schedule_state.dart';
import '../../../core/theme.dart';
import '../../../data/models/schedule_model.dart';

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

  Map<String, List<ScheduleModel>> _groupSchedulesByDay(
    List<ScheduleModel> schedules,
  ) {
    final Map<String, List<ScheduleModel>> grouped = {};
    for (var s in schedules) {
      // Normalize day string
      final day = s.day.toLowerCase().trim();
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(s);
    }
    return grouped;
  }

  List<String> _getSortedDays(List<String> days) {
    final dayOrder = {
      'senin': 1,
      'selasa': 2,
      'rabu': 3,
      'kamis': 4,
      'jumat': 5,
      'sabtu': 6,
      'minggu': 7,
    };
    days.sort((a, b) {
      final da = dayOrder[a.toLowerCase()] ?? 8;
      final db = dayOrder[b.toLowerCase()] ?? 8;
      return da.compareTo(db);
    });
    return days;
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
      child: BlocBuilder<AdminScheduleBloc, AdminScheduleState>(
        builder: (context, state) {
          if (state is AdminScheduleLoaded) {
            // Deduplicate schedules by ID
            final uniqueSchedules = {
              for (var s in state.schedules) s.id: s
            }.values.toList();

            // Group data
            final grouped = _groupSchedulesByDay(uniqueSchedules);
            final sortedDays = _getSortedDays(grouped.keys.toList());

            if (sortedDays.isEmpty) {
              return _buildScaffold(
                body: const Center(child: Text('Belum ada jadwal')),
              );
            }

            return DefaultTabController(
              length: sortedDays.length,
              child: _buildScaffold(
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                      ),
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                      dividerColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      tabs: sortedDays
                          .map(
                            (day) => Tab(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(day.toUpperCase()),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                body: TabBarView(
                  children: sortedDays.map((day) {
                    final daySchedules = grouped[day]!;
                    // Sort by time
                    daySchedules.sort(
                      (a, b) => a.startTime.compareTo(b.startTime),
                    );
                    return _buildScheduleList(daySchedules);
                  }).toList(),
                ),
              ),
            );
          } else if (state is AdminScheduleLoading) {
            return _buildScaffold(
              body: const Center(child: CircularProgressIndicator()),
            );
          } else {
            return _buildScaffold(
              body: const Center(child: Text('Gagal memuat jadwal')),
            );
          }
        },
      ),
    );
  }

  Widget _buildScaffold({PreferredSizeWidget? bottom, Widget? body}) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal ${widget.teacher.name}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: bottom,
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
      body: body,
    );
  }

  Widget _buildScheduleList(List<ScheduleModel> schedules) {
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
                  '${item.startTime} - ${item.endTime}',
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
}
