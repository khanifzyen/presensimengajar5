import 'dart:io';
import 'package:safe_device/safe_device.dart';
import '../../../core/utils/file_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/attendance_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
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
      // 1. Check Developer Mode (Android)
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

      // 2. Check Active Session
      // Fetch today's history locally first or from API
      // Since we don't have a reliable local state of all schedules, we ask the server/repo
      final today = DateTime.now();
      final history = await attendanceRepository.getAttendanceHistory(
        event.teacherId,
        startDate: DateTime(today.year, today.month, today.day),
        endDate: DateTime(today.year, today.month, today.day, 23, 59, 59),
      );

      // Check if any attendance has NO check-out (active)
      // Limit this check to check-ins that are NOT the current one (obviously we haven't checked in yet)
      // But if we have an active session for Schedule A, we can't check in to Schedule B.
      final hasActiveSession = history.any((a) => a.checkOut == null);
      if (hasActiveSession) {
        emit(
          const AttendanceError(
            'Anda sedang aktif di kelas lain. Silakan Check-Out terlebih dahulu.',
          ),
        );
        return;
      }

      // 3. Resize Image
      final compressedFile = await FileUtils.compressImage(event.file);

      // 4. Call Repository
      final attendance = await attendanceRepository.checkIn(
        teacherId: event.teacherId,
        scheduleId: event.scheduleId,
        latitude: event.lat,
        longitude: event.lng,
        photo: compressedFile,
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
