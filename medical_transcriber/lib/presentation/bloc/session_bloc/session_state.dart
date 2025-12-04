part of 'session_bloc.dart';

@immutable
sealed class SessionState {}

final class SessionInitial extends SessionState {}

class SessionLoadingState extends SessionState {}

class SessionLoadedSuccessState extends SessionState {
  final List<SessionModel> sessions;
  SessionLoadedSuccessState({required this.sessions});
}

class SessionErrorState extends SessionState {
  final String message;
  SessionErrorState({required this.message});
}