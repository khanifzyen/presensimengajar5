import 'package:pocketbase/pocketbase.dart';
import '../../domain/repositories/settings_repository.dart';
import 'package:presensimengajar_flutter/features/admin/dashboard/data/models/misc_models.dart';

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
                'key = "location_lat" || key = "location_lng" || key = "location_radius" || key = "tolerance_minutes"',
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
        } else if (setting.key == 'tolerance_minutes') {
          config['tolerance_minutes'] = int.tryParse(setting.value) ?? 15;
        }
      }

      return config;
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      // We need to find the record ID for each setting key
      final result = await pb
          .collection('settings')
          .getFullList(
            filter:
                'key = "location_lat" || key = "location_lng" || key = "location_radius" || key = "tolerance_minutes"',
          );

      // Map key to ID
      final Map<String, String> keyToId = {
        for (var item in result) item.getStringValue('key'): item.id,
      };

      // Helper to update or create
      Future<void> updateOrCreate(String key, String value) async {
        if (keyToId.containsKey(key)) {
          await pb
              .collection('settings')
              .update(keyToId[key]!, body: {'value': value});
        } else {
          await pb
              .collection('settings')
              .create(
                body: {
                  'key': key,
                  'value': value,
                  'description': 'System setting for $key',
                },
              );
        }
      }

      if (settings.containsKey('office_latitude')) {
        await updateOrCreate(
          'location_lat',
          settings['office_latitude'].toString(),
        );
      }
      if (settings.containsKey('office_longitude')) {
        await updateOrCreate(
          'location_lng',
          settings['office_longitude'].toString(),
        );
      }
      if (settings.containsKey('radius_meter')) {
        await updateOrCreate(
          'location_radius',
          settings['radius_meter'].toString(),
        );
      }
      if (settings.containsKey('tolerance_minutes')) {
        await updateOrCreate(
          'tolerance_minutes',
          settings['tolerance_minutes'].toString(),
        );
      }
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }
}
