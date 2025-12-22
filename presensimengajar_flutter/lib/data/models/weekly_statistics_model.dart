class WeeklyStatisticsModel {
  final int totalScheduled; // Total classes scheduled this week
  final int classesAttended; // Kelas Diampu (with attendance record)
  final int lateArrivals; // Terlambat (check-in > start time + grace)
  final int leaveRequests; // Izin (approved leave requests)

  final int alpha; // Calculated Alpha based on passed days

  WeeklyStatisticsModel({
    required this.totalScheduled,
    required this.classesAttended,
    required this.lateArrivals,
    required this.leaveRequests,
    required this.alpha,
  });

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
      alpha: 0,
    );
  }
}
