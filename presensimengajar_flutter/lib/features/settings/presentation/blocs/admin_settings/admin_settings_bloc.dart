import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'admin_settings_event.dart';
import 'admin_settings_state.dart';

class AdminSettingsBloc extends Bloc<AdminSettingsEvent, AdminSettingsState> {
  final SettingsRepository settingsRepository;

  AdminSettingsBloc(this.settingsRepository) : super(AdminSettingsInitial()) {
    on<AdminSettingsFetch>(_onFetchSettings);
    on<AdminSettingsUpdate>(_onUpdateSettings);
  }

  Future<void> _onFetchSettings(
    AdminSettingsFetch event,
    Emitter<AdminSettingsState> emit,
  ) async {
    emit(AdminSettingsLoading());
    try {
      final settings = await settingsRepository.getAttendanceSettings();
      emit(
        AdminSettingsLoaded(
          latitude: settings['office_latitude'] as double? ?? 0.0,
          longitude: settings['office_longitude'] as double? ?? 0.0,
          radius: settings['radius_meter'] as double? ?? 100.0,
          tolerance: settings['tolerance_minutes'] as int? ?? 15,
        ),
      );
    } catch (e) {
      emit(AdminSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
    AdminSettingsUpdate event,
    Emitter<AdminSettingsState> emit,
  ) async {
    emit(AdminSettingsLoading());
    try {
      final Map<String, dynamic> updates = {};
      if (event.latitude != null) updates['office_latitude'] = event.latitude;
      if (event.longitude != null)
        updates['office_longitude'] = event.longitude;
      if (event.radius != null) updates['radius_meter'] = event.radius;
      if (event.tolerance != null)
        updates['tolerance_minutes'] = event.tolerance;

      await settingsRepository.updateSettings(updates);

      // Fetch latest values to update UI
      final settings = await settingsRepository.getAttendanceSettings();
      emit(AdminSettingsSuccess('Pengaturan berhasil diperbarui'));
      emit(
        AdminSettingsLoaded(
          latitude: settings['office_latitude'] as double? ?? 0.0,
          longitude: settings['office_longitude'] as double? ?? 0.0,
          radius: settings['radius_meter'] as double? ?? 100.0,
          tolerance: settings['tolerance_minutes'] as int? ?? 15,
        ),
      );
    } catch (e) {
      emit(AdminSettingsError(e.toString()));
    }
  }
}
