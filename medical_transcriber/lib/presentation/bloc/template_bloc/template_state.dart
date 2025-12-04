part of 'template_bloc.dart';

@immutable
sealed class TemplateState {}

final class TemplateInitial extends TemplateState {}

class TemplateLoadingState extends TemplateState {}

class TemplateLoadedSuccessState extends TemplateState {
  final List<TemplateModel> templates;
  TemplateLoadedSuccessState({required this.templates});
}

class TemplateErrorState extends TemplateState {
  final String message;
  TemplateErrorState({required this.message});
}