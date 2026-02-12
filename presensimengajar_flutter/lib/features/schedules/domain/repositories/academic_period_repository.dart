import '../../../admin/dashboard/data/models/master_models.dart';

abstract class AcademicPeriodRepository {
  Future<List<AcademicPeriodModel>> getAcademicPeriods();
  Future<AcademicPeriodModel> createAcademicPeriod(Map<String, dynamic> body);
  Future<AcademicPeriodModel> updateAcademicPeriod(
    String id,
    Map<String, dynamic> body,
  );
  Future<void> deleteAcademicPeriod(String id);
  Future<void> setActivePeriod(String id);
}
