part of 'recording_bloc.dart';

enum RecordingStatus {
  idle,
  recording,
  paused,
  stopping,
  finished,
}

class RecordingState extends Equatable {
  final RecordingStatus status;
  final double audioLevel;
  final List<Map<String, dynamic>> receivedChunks;
  final String? route;

  const RecordingState({
    required this.status,
    required this.audioLevel,
    required this.receivedChunks,
    required this.route,
  });

  factory RecordingState.initial() => RecordingState(
    status: RecordingStatus.idle,
    audioLevel: 0.0,
    receivedChunks: const [],
    route: null,
  );

  RecordingState copyWith({
    RecordingStatus? status,
    double? audioLevel,
    List<Map<String, dynamic>>? receivedChunks,
    String? route,
  }) {
    return RecordingState(
      status: status ?? this.status,
      audioLevel: audioLevel ?? this.audioLevel,
      receivedChunks: receivedChunks ?? this.receivedChunks,
      route: route ?? this.route,
    );
  }

  @override
  List<Object?> get props => [status, audioLevel, receivedChunks, route];
}