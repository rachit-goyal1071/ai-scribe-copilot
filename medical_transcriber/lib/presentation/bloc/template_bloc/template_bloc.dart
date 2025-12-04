import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:medical_transcriber/domain/models/template_model.dart';
import 'package:medical_transcriber/domain/repositories/template_repository.dart';
import 'package:meta/meta.dart';

part 'template_event.dart';
part 'template_state.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final TemplateRepository repo;

  TemplateBloc(this.repo) : super(TemplateInitial()) {
    on<LoadTemplatesEvent>(loadTemplatesEvent);
  }

  FutureOr<void> loadTemplatesEvent(LoadTemplatesEvent event, Emitter<TemplateState> emit) async {
    emit(TemplateLoadingState());
    try {
      final templates = await repo.getUserTemplates(event.userId);
      emit(TemplateLoadedSuccessState(templates: templates));
    } catch (e) {
      emit(TemplateErrorState(message: e.toString()));
    }
  }
}
