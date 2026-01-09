import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:medical_transcriber/main.dart';
import 'package:meta/meta.dart';

import '../../../domain/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repo;

  UserBloc(this.repo) : super(UserInitial()) {
    on<FetchUserIdEvent>(fetchUserIdEvent);
  }

  FutureOr<void> fetchUserIdEvent(FetchUserIdEvent event, Emitter<UserState> emit) async{
    emit(UserLoadingState());

    try {
      final user = await repo.getUserIdByEmail(event.email);
      userIdMain = user.value;
      emit(UserLoadedSuccessState(user.value));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('UserBloc: fetchUserId failed: $e');
      }
      emit(UserErrorState(e.toString()));
    }
  }
}
