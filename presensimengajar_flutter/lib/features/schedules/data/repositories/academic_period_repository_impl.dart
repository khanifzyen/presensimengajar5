import 'package:pocketbase/pocketbase.dart';
import '../../../admin/dashboard/data/models/master_models.dart';
import '../../domain/repositories/academic_period_repository.dart';

class AcademicPeriodRepositoryImpl implements AcademicPeriodRepository {
  final PocketBase pb;

  AcademicPeriodRepositoryImpl(this.pb);

  @override
  Future<List<AcademicPeriodModel>> getAcademicPeriods() async {
    try {
      final records = await pb
          .collection('academic_periods')
          .getFullList(sort: '-start_date');
      return records.map((r) => AcademicPeriodModel.fromRecord(r)).toList();
    } catch (e) {
      throw Exception('Failed to fetch academic periods: $e');
    }
  }

  @override
  Future<AcademicPeriodModel> createAcademicPeriod(
    Map<String, dynamic> body,
  ) async {
    try {
      // If setting as active, first unset other active periods if necessary
      // But typically backend hooks should handle this unique constraint or client does it sequentially
      // For simplicity, we just create.
      final record = await pb.collection('academic_periods').create(body: body);
      return AcademicPeriodModel.fromRecord(record);
    } catch (e) {
      throw Exception('Failed to create academic period: $e');
    }
  }

  @override
  Future<AcademicPeriodModel> updateAcademicPeriod(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final record = await pb
          .collection('academic_periods')
          .update(id, body: body);
      return AcademicPeriodModel.fromRecord(record);
    } catch (e) {
      throw Exception('Failed to update academic period: $e');
    }
  }

  @override
  Future<void> deleteAcademicPeriod(String id) async {
    try {
      await pb.collection('academic_periods').delete(id);
    } catch (e) {
      throw Exception('Failed to delete academic period: $e');
    }
  }

  @override
  Future<void> setActivePeriod(String id) async {
    try {
      // This might need a batch operation or cloud function to ensure only one is active
      // Client-side implementation:
      // 1. Get current active one(s) and set to inactive
      final activePeriods = await pb
          .collection('academic_periods')
          .getFullList(filter: 'is_active = true');
      for (var p in activePeriods) {
        if (p.id != id) {
          await pb
              .collection('academic_periods')
              .update(p.id, body: {'is_active': false});
        }
      }
      // 2. Set target to active
      await pb
          .collection('academic_periods')
          .update(id, body: {'is_active': true});
    } catch (e) {
      throw Exception('Failed to set active period: $e');
    }
  }
}
