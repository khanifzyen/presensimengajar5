import 'package:pocketbase/pocketbase.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/misc_models.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final PocketBase pb;

  SettingsRepositoryImpl(this.pb);

  @override
  Future<Map<String, dynamic>> getAttendanceSettings() async {
    try {
      // Fetch settings with specific keys or just fetch all and filter
      // For efficiency, we can filter by key if needed, but often fetching all is file for settings
      final result = await pb
          .collection('settings')
          .getFullList(
            filter:
                'key = "location_lat" || key = "location_lng" || key = "location_radius"',
          );

      final settings = result
          .map((record) => SettingModel.fromRecord(record))
          .toList();

      final Map<String, dynamic> config = {};

      for (var setting in settings) {
        if (setting.key == 'location_lat') {
          config['office_latitude'] = double.tryParse(setting.value) ?? 0.0;
        } else if (setting.key == 'location_lng') {
          config['office_longitude'] = double.tryParse(setting.value) ?? 0.0;
        } else if (setting.key == 'location_radius') {
          config['radius_meter'] = double.tryParse(setting.value) ?? 0.0;
        }
      }

      return config;
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }
}
