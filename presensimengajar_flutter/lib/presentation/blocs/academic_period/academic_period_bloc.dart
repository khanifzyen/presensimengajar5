import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../data/models/academic_period_model.dart';
import 'academic_period_event.dart';
import 'academic_period_state.dart';

class AcademicPeriodBloc
    extends Bloc<AcademicPeriodEvent, AcademicPeriodState> {
  final PocketBase pb;

  AcademicPeriodBloc(this.pb) : super(AcademicPeriodInitial()) {
    on<FetchAcademicPeriods>(_onFetchAcademicPeriods);
    on<SelectAcademicPeriod>(_onSelectAcademicPeriod);
  }

  Future<void> _onFetchAcademicPeriods(
    FetchAcademicPeriods event,
    Emitter<AcademicPeriodState> emit,
  ) async {
    emit(AcademicPeriodLoading());
    try {
      final records = await pb
          .collection('academic_periods')
          .getFullList(sort: '-start_date');
      final periods = records
          .map((r) => AcademicPeriodModel.fromRecord(r))
          .toList();

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
}
