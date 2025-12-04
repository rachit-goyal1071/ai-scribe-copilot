part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

class FetchUserIdEvent extends UserEvent {
  final String email;
  FetchUserIdEvent(this.email);
}


