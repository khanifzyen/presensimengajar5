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
                'key = "office_latitude" || key = "office_longitude" || key = "radius_meter"',
          );

      final settings = result
          .map((record) => SettingModel.fromRecord(record))
          .toList();

      final Map<String, dynamic> config = {};

      for (var setting in settings) {
        if (setting.key == 'office_latitude') {
          config['office_latitude'] = double.tryParse(setting.value) ?? 0.0;
        } else if (setting.key == 'office_longitude') {
          config['office_longitude'] = double.tryParse(setting.value) ?? 0.0;
        } else if (setting.key == 'radius_meter') {
          config['radius_meter'] = double.tryParse(setting.value) ?? 0.0;
        }
      }

      return config;
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }
}
