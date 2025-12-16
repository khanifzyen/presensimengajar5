class WeeklyStatisticsModel {
  final int totalScheduled; // Total classes scheduled this week
  final int classesAttended; // Kelas Diampu (with attendance record)
  final int lateArrivals; // Terlambat (check-in > start time + grace)
  final int leaveRequests; // Izin (approved leave requests)

  WeeklyStatisticsModel({
    required this.totalScheduled,
    required this.classesAttended,
    required this.lateArrivals,
    required this.leaveRequests,
  });

  // Calculated field: Alpha = Total Scheduled - (Attended + Leave)
  int get alpha {
    final absences = totalScheduled - (classesAttended + leaveRequests);
    return absences < 0 ? 0 : absences; // Ensure non-negative
  }

  // For debugging
  @override
  String toString() {
    return 'WeeklyStatistics(scheduled: $totalScheduled, attended: $classesAttended, '
        'late: $lateArrivals, leave: $leaveRequests, alpha: $alpha)';
  }

  // Factory for empty statistics
  factory WeeklyStatisticsModel.empty() {
    return WeeklyStatisticsModel(
      totalScheduled: 0,
      classesAttended: 0,
      lateArrivals: 0,
      leaveRequests: 0,
    );
  }
}
