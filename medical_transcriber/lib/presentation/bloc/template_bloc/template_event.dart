part of 'template_bloc.dart';

@immutable
sealed class TemplateEvent {}

class LoadTemplatesEvent extends TemplateEvent {
  final String userId;
  LoadTemplatesEvent({required this.userId});
}