import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/content_repository.dart';
import 'content_event.dart';
import 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final ContentRepository repository;

  ContentBloc(this.repository) : super(ContentInitial()) {
    on<FetchGuides>(_onFetchGuides);
    on<FetchAppInfo>(_onFetchAppInfo);
  }

  Future<void> _onFetchGuides(
    FetchGuides event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    try {
      final guides = await repository.getGuides();
      emit(GuidesLoaded(guides));
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  Future<void> _onFetchAppInfo(
    FetchAppInfo event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    try {
      final info = await repository.getAppInfo();
      emit(AppInfoLoaded(info));
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }
}
