import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../domain/repositories/leave_repository.dart';
import '../models/leave_request_model.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final PocketBase pb;

  LeaveRepositoryImpl(this.pb);

  @override
  Future<LeaveRequestModel> requestLeave({
    required String teacherId,
    required String type,
    required String startDate,
    required String endDate,
    required String reason,
    File? attachment,
  }) async {
    final body = {
      'teacher_id': teacherId,
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'status': 'pending',
    };

    List<http.MultipartFile> files = [];
    if (attachment != null) {
      final filename = attachment.path.split(Platform.pathSeparator).last;
      files.add(
        http.MultipartFile.fromBytes(
          'attachment',
          await attachment.readAsBytes(),
          filename: filename,
        ),
      );
    }

    final record = await pb
        .collection(AppCollections.leaveRequests)
        .create(body: body, files: files);

    return LeaveRequestModel.fromRecord(record);
  }

  @override
  Future<List<LeaveRequestModel>> getLeaveHistory(String teacherId) async {
    final records = await pb
        .collection(AppCollections.leaveRequests)
        .getFullList(filter: 'teacher_id="$teacherId"', sort: '-created');

    return records.map((r) => LeaveRequestModel.fromRecord(r)).toList();
  }
}
