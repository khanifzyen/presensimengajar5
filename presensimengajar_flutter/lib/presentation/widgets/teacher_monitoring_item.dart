import 'package:flutter/material.dart';
import '../../data/models/teacher_model.dart';
import '../../core/theme.dart';

class TeacherMonitoringItem extends StatelessWidget {
  final TeacherModel teacher;
  final String subjectInfo;
  final String categoryBadge;
  final String statusText;
  final String statusColor;

  const TeacherMonitoringItem({
    super.key,
    required this.teacher,
    required this.subjectInfo,
    required this.categoryBadge,
    required this.statusText,
    required this.statusColor,
  });

  Color _getStatusColor() {
    switch (statusColor) {
      case 'present':
        return AppTheme.statGreen;
      case 'late':
        return AppTheme.statYellow;
      case 'absent':
        return AppTheme.statRed;
      case 'permit':
        return AppTheme.statOrange;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor() {
    return categoryBadge == 'Tetap' ? AppTheme.statBlue : AppTheme.statGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Teacher photo
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            backgroundImage:
                teacher.photo.isNotEmpty && teacher.photo.startsWith('http')
                ? NetworkImage(teacher.photo)
                : null,
            child: teacher.photo.isEmpty || !teacher.photo.startsWith('http')
                ? Text(
                    teacher.name.isNotEmpty
                        ? teacher.name[0].toUpperCase()
                        : 'G',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Teacher info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subjectInfo,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    categoryBadge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
