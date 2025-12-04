import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:medical_transcriber/domain/repositories/session_repository.dart';
import 'package:meta/meta.dart';

import '../../../domain/models/session_model.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionRepository repo;

  SessionBloc(this.repo) : super(SessionInitial()) {
    on<LoadAllSessionsEvent>(loadAllSessionsEvent);
  }

  FutureOr<void> loadAllSessionsEvent(LoadAllSessionsEvent event, Emitter<SessionState> emit) async {
    emit(SessionLoadingState());
    try {
      final sessions = await repo.getAllSessions(event.userId);
      emit(SessionLoadedSuccessState(sessions: sessions));
    } catch (e) {
      emit(SessionErrorState(message: e.toString()));
    }
  }
}
