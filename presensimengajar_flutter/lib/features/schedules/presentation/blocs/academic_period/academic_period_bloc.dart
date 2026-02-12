import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../admin/dashboard/data/models/master_models.dart';
import '../../../domain/repositories/academic_period_repository.dart';
import 'academic_period_event.dart';
import 'academic_period_state.dart';

class AcademicPeriodBloc
    extends Bloc<AcademicPeriodEvent, AcademicPeriodState> {
  final AcademicPeriodRepository repository;

  AcademicPeriodBloc(this.repository) : super(AcademicPeriodInitial()) {
    on<FetchAcademicPeriods>(_onFetchAcademicPeriods);
    on<SelectAcademicPeriod>(_onSelectAcademicPeriod);
    on<CreateAcademicPeriod>(_onCreateAcademicPeriod);
    on<UpdateAcademicPeriod>(_onUpdateAcademicPeriod);
    on<DeleteAcademicPeriod>(_onDeleteAcademicPeriod);
    on<SetActivePeriod>(_onSetActivePeriod);
  }

  Future<void> _onFetchAcademicPeriods(
    FetchAcademicPeriods event,
    Emitter<AcademicPeriodState> emit,
  ) async {
    emit(AcademicPeriodLoading());
    try {
      final periods = await repository.getAcademicPeriods();

      // Select active period by default
      AcademicPeriodModel? activePeriod;
      try {
        activePeriod = periods.firstWhere((p) => p.isActive);
      } catch (_) {
        if (periods.isNotEmpty) {
          activePeriod = periods.first;
        }
      }

      emit(
        AcademicPeriodLoaded(periods: periods, selectedPeriod: activePeriod),
      );
    } catch (e) {
      emit(AcademicPeriodError(e.toString()));
    }
  }

  void _onSelectAcademicPeriod(
    SelectAcademicPeriod event,
    Emitter<AcademicPeriodState> emit,
  ) {
    if (state is AcademicPeriodLoaded) {
      final currentState = state as AcademicPeriodLoaded;
      emit(
        AcademicPeriodLoaded(
          periods: currentState.periods,
          selectedPeriod: event.period,
        ),
      );
    }
  }

  Future<void> _onCreateAcademicPeriod(
    CreateAcademicPeriod event,
    Emitter<AcademicPeriodState> emit,
  ) async {
    emit(AcademicPeriodLoading());
    try {
      await repository.createAcademicPeriod(event.data);
      emit(const AcademicPeriodSuccess('Periode akademik berhasil dibuat'));
      add(FetchAcademicPeriods());
    } catch (e) {
      emit(AcademicPeriodError(e.toString()));
      add(FetchAcademicPeriods());
    }
  }

  Future<void> _onUpdateAcademicPeriod(
    UpdateAcademicPeriod event,
    Emitter<AcademicPeriodState> emit,
  ) async {
    emit(AcademicPeriodLoading());
    try {
      await repository.updateAcademicPeriod(event.id, event.data);
      emit(const AcademicPeriodSuccess('Periode akademik berhasil diperbarui'));
      add(FetchAcademicPeriods());
    } catch (e) {
      emit(AcademicPeriodError(e.toString()));
      add(FetchAcademicPeriods());
    }
  }

  Future<void> _onDeleteAcademicPeriod(
    DeleteAcademicPeriod event,
    Emitter<AcademicPeriodState> emit,
  ) async {
    emit(AcademicPeriodLoading());
    try {
      await repository.deleteAcademicPeriod(event.id);
      emit(const AcademicPeriodSuccess('Periode akademik berhasil dihapus'));
      add(FetchAcademicPeriods());
    } catch (e) {
      emit(AcademicPeriodError(e.toString()));
      add(FetchAcademicPeriods());
    }
  }

  Future<void> _onSetActivePeriod(
    SetActivePeriod event,
    Emitter<AcademicPeriodState> emit,
  ) async {
    emit(AcademicPeriodLoading());
    try {
      await repository.setActivePeriod(event.id);
      emit(const AcademicPeriodSuccess('Periode aktif berhasil diubah'));
      add(FetchAcademicPeriods());
    } catch (e) {
      emit(AcademicPeriodError(e.toString()));
      add(FetchAcademicPeriods());
    }
  }
}
