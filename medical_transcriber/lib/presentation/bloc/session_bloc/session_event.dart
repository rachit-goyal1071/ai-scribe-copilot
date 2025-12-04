part of 'session_bloc.dart';

@immutable
sealed class SessionEvent {}

class LoadAllSessionsEvent extends SessionEvent {
  final String userId;
  LoadAllSessionsEvent({required this.userId});
}
