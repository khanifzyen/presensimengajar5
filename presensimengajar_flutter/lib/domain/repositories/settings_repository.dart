abstract class SettingsRepository {
  /// Fetch all attendance-related settings
  /// Returns a Map with keys: office_latitude, office_longitude, radius_meter
  Future<Map<String, dynamic>> getAttendanceSettings();
}
