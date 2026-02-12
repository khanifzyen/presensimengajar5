abstract class ContentRepository {
  Future<List<Map<String, dynamic>>> getGuides();
  Future<Map<String, dynamic>> getAppInfo();
}
