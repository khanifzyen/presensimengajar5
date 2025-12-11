import 'dart:io';
import '../../data/models/leave_request_model.dart';

abstract class LeaveRepository {
  Future<LeaveRequestModel> requestLeave({
    required String teacherId,
    required String type,
    required String startDate,
    required String endDate,
    required String reason,
    File? attachment,
  });

  Future<List<LeaveRequestModel>> getLeaveHistory(String teacherId);
}
