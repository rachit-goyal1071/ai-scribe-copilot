part of 'recording_bloc.dart';

abstract class RecordingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartRecordingEvent extends RecordingEvent {
  final String patientId;
  final String userId;
  final String patientName;
  final String templateId;
  StartRecordingEvent({
    required this.patientId,
    required this.userId,
    required this.patientName,
    required this.templateId,
  });
}

class PauseRecordingEvent extends RecordingEvent {}

class ResumeRecordingEvent extends RecordingEvent {}

class StopRecordingEvent extends RecordingEvent {
  final bool isLast;
  StopRecordingEvent({required this.isLast});
}

class NewAudioLevelEvent extends RecordingEvent {
  final double level;
  NewAudioLevelEvent(this.level);

  @override
  List<Object?> get props => [level];
}

class NewChunkEvent extends RecordingEvent {
  final String filePath;
  final int chunkNumber;
  final bool isLast;

  NewChunkEvent({
    required this.filePath,
    required this.chunkNumber,
    required this.isLast,
  });

  @override
  List<Object?> get props => [filePath, chunkNumber, isLast];
}

class AudioRouteChangedEvent extends RecordingEvent {
  final String route;

  AudioRouteChangedEvent(this.route);

  @override
  List<Object?> get props => [route];
}