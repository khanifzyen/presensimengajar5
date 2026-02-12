import 'dart:io';
import 'package:safe_device/safe_device.dart';
import '../../../../../core/utils/file_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/attendance_repository.dart';
import '../../../../settings/domain/repositories/settings_repository.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/weekly_statistics_model.dart';

import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository attendanceRepository;
  final SettingsRepository? settingsRepository;

  AttendanceBloc({required this.attendanceRepository, this.settingsRepository})
    : super(AttendanceInitial()) {
    on<AttendanceCheckIn>(_onAttendanceCheckIn);
    on<AttendanceCheckOut>(_onAttendanceCheckOut);
    on<AttendanceFetchHistory>(_onAttendanceFetchHistory);
    on<AttendanceFetchForSchedules>(_onAttendanceFetchForSchedules);
    on<AttendanceFetchWeeklyStatistics>(_onFetchWeeklyStatistics);
    on<AttendanceFetchDashboardData>(_onFetchDashboardData);
    on<AttendanceFetchSettings>(_onFetchSettings);
  }

  Future<void> _onFetchSettings(
    AttendanceFetchSettings event,
    Emitter<AttendanceState> emit,
  ) async {
    if (settingsRepository == null) return;
    // Don't emit loading here to avoid flicker if just refreshing settings in BG
    // Or do emit loading if it's critical. Let's not emit global loading, just emit state when ready.
    try {
      final settings = await settingsRepository!.getAttendanceSettings();
      emit(AttendanceSettingsLoaded(settings));
    } catch (e) {
      // For settings, maybe just log error or emit generic error?
      // Since it's background/init, maybe don't block UI with error screen.
      // But for now, let's emit error to be safe.
      emit(AttendanceError('Gagal memuat pengaturan: $e'));
    }
  }

  Future<void> _onAttendanceCheckIn(
    AttendanceCheckIn event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      // 0. Fetch Settings for Tolerance
      int toleranceMinutes = 15; // Default
      if (settingsRepository != null) {
        final settings = await settingsRepository!.getAttendanceSettings();
        if (settings.containsKey('tolerance_minutes')) {
          toleranceMinutes = settings['tolerance_minutes'] as int;
        }
      }

      final now = DateTime.now();

      // 1. Time Window Validation
      String attendanceStatus = 'hadir';
      final startTimeParts = event.scheduleStartTime.split(':');
      final endTimeParts = event.scheduleEndTime.split(':');

      if (startTimeParts.length == 2 && endTimeParts.length == 2) {
        final startDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(startTimeParts[0]),
          int.parse(startTimeParts[1]),
        );

        final earliestCheckIn = startDateTime.subtract(
          Duration(minutes: toleranceMinutes),
        );

        // Late threshold: Start + tolerance
        final lateThreshold = startDateTime.add(
          Duration(minutes: toleranceMinutes),
        );

        if (now.isBefore(earliestCheckIn)) {
          emit(
            AttendanceError(
              'Belum waktunya check-in. Harap tunggu hingga $toleranceMinutes menit sebelum jadwal dimulai.',
            ),
          );
          return;
        }

        if (now.isAfter(lateThreshold)) {
          attendanceStatus = 'telat';
        }
      }

      // 2. Check Developer Mode (Android)
      if (Platform.isAndroid) {
        bool isDevMode = await SafeDevice.isDevelopmentModeEnable;
        if (isDevMode) {
          emit(
            const AttendanceError(
              'Mode Pengembang (Developer Mode) harus dimatikan untuk melakukan presensi.',
            ),
          );
          return;
        }
      }

      // 3. Get History for Duplication & Active Session Check
      final history = await attendanceRepository.getAttendanceHistory(
        event.teacherId,
        startDate: DateTime(now.year, now.month, now.day),
        endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );

      // Check Duplicate for THIS schedule
      final isDuplicate = history.any(
        (a) => a.scheduleId == event.scheduleId && a.checkIn != null,
      );
      if (isDuplicate) {
        emit(
          const AttendanceError(
            'Anda sudah pernah check-in untuk jadwal ini hari ini.',
          ),
        );
        return;
      }

      // Check Active Session in OTHER schedules
      // If I have an active session (no checkout), I cannot start another.
      final hasActiveSession = history.any((a) => a.checkOut == null);
      if (hasActiveSession) {
        emit(
          const AttendanceError(
            'Anda sedang aktif di kelas lain. Silakan Check-Out terlebih dahulu.',
          ),
        );
        return;
      }

      // 4. Resize Image
      final compressedFile = await FileUtils.compressImage(event.file);

      // 5. Call Repository
      final attendance = await attendanceRepository.checkIn(
        teacherId: event.teacherId,
        scheduleId: event.scheduleId,
        latitude: event.lat,
        longitude: event.lng,
        photo: compressedFile,
        status: attendanceStatus,
      );
      emit(AttendanceSuccess(attendance));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onAttendanceCheckOut(
    AttendanceCheckOut event,
    Emitter<AttendanceState> emit,
  ) async {
    final now = DateTime.now();
    final difference = now.difference(event.checkInTime).inMinutes;

    if (difference < 10) {
      emit(
        AttendanceError(
          'Anda baru bisa melakukan Check-Out setelah 10 menit check-in. Sisa waktu: ${10 - difference} menit.',
        ),
      );
      return;
    }

    emit(AttendanceLoading());
    try {
      final attendance = await attendanceRepository.checkOut(
        attendanceId: event.attendanceId,
        latitude: event.lat,
        longitude: event.lng,
      );
      emit(AttendanceSuccess(attendance));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onAttendanceFetchHistory(
    AttendanceFetchHistory event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final history = await attendanceRepository.getAttendanceHistory(
        event.teacherId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(AttendanceHistoryLoaded(history));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onAttendanceFetchForSchedules(
    AttendanceFetchForSchedules event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendanceMap = await attendanceRepository.getAttendanceBySchedules(
        event.teacherId,
        event.scheduleIds,
        event.startDate,
        event.endDate,
      );
      emit(AttendanceScheduleMapLoaded(attendanceMap));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onFetchWeeklyStatistics(
    AttendanceFetchWeeklyStatistics event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      final statistics = await attendanceRepository.getWeeklyStatistics(
        teacherId: event.teacherId,
        weekStart: event.weekStart,
        weekEnd: event.weekEnd,
      );
      emit(AttendanceStatisticsLoaded(statistics));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onFetchDashboardData(
    AttendanceFetchDashboardData event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final results = await Future.wait([
        attendanceRepository.getWeeklyStatistics(
          teacherId: event.teacherId,
          weekStart: event.weekStart,
          weekEnd: event.weekEnd,
        ),
        attendanceRepository.getAttendanceBySchedules(
          event.teacherId,
          event.scheduleIds,
          event.weekStart,
          event.weekEnd,
        ),
        attendanceRepository.getOngoingAttendance(event.teacherId),
      ]);

      final statistics = results[0] as WeeklyStatisticsModel;
      final attendanceMap = results[1] as Map<String, AttendanceModel>;
      final ongoingAttendances = results[2] as List<AttendanceModel>;

      emit(
        AttendanceDashboardLoaded(
          statistics: statistics,
          attendanceMap: attendanceMap,
          ongoingAttendances: ongoingAttendances,
        ),
      );
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
