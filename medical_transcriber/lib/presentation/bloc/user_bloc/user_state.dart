part of 'user_bloc.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

class UserLoadingState extends UserState {}

final class UserLoadedSuccessState extends UserState {
  final String userId;
  UserLoadedSuccessState(this.userId);
}

final class UserErrorState extends UserState {
  final String message;
  UserErrorState(this.message);
}
