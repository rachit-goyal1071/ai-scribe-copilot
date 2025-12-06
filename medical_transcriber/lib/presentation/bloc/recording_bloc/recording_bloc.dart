import 'dart:async';

import'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/native/native_audio_service.dart';
import '../../../data/local/chunk_local_data_source.dart';
import '../../../data/local/chunk_status.dart';
import '../../../data/local/recording_chunk.dart';
import '../../../domain/repositories/recording_repository.dart';

part 'recording_event.dart';
part 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final RecordingRepository repo;
  final ChunkLocalDataSource local;
  String? sessionId;
  final NativeAudioService _native = NativeAudioService();

  StreamSubscription? _levelSub;
  StreamSubscription? _chunkSub;
  StreamSubscription? _routeSub;

  RecordingBloc(this.repo, this.local) : super(RecordingState.initial()) {
    on<StartRecordingEvent>(onStart);
    on<PauseRecordingEvent>(onPause);
    on<ResumeRecordingEvent>(onResume);
    on<StopRecordingEvent>(onStop);

    on<NewAudioLevelEvent>(onNewLevel);
    on<NewChunkEvent>(onNewChunk);
    on<AudioRouteChangedEvent>(onRouteChanged);
  }

  Future<void> onStart(
      StartRecordingEvent event,
      Emitter<RecordingState> emit,
      ) async {
    try {
      sessionId = await repo.createSession(
        patientId: event.patientId,
        userId: event.userId,
        patientName: event.patientName,
        status: "recording",
        startTime: DateTime.now().toIso8601String(),
        templateId: "",
      );
      // emit(RecordingSessionCreated(sessionId!));
    emit(state.copyWith(status: RecordingStatus.recording));
    } catch (err) {
      print("Error creating session: $err");
    }

    ensureMicPermission();

    _levelSub?.cancel();
    _chunkSub?.cancel();
    _routeSub?.cancel();

    _levelSub = _native.audioLevels().listen((level) {
      add(NewAudioLevelEvent(level));
    });

    _chunkSub = _native.audioChunks().listen((chunk) {
      add(NewChunkEvent(
        filePath: chunk["filePath"],
        chunkNumber: chunk["chunkNumber"],
        isLast: chunk["isLast"],
      ));
    });

    _routeSub = _native.audioRoutes().listen((route) {
      add(AudioRouteChangedEvent(route));
    });

    print(sessionId);
    await _native.startRecording(sessionId!);
  }

  Future<bool> ensureMicPermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> onPause(
      PauseRecordingEvent event,
      Emitter<RecordingState> emit,
      ) async {
    await _native.pauseRecording();
    emit(state.copyWith(status: RecordingStatus.paused));
  }

  Future<void> onResume(
      ResumeRecordingEvent event,
      Emitter<RecordingState> emit,
      ) async {
    await _native.resumeRecording();
    emit(state.copyWith(status: RecordingStatus.recording));
  }

  bool hasStopped = false;

  Future<void> onStop(
      StopRecordingEvent event,
      Emitter<RecordingState> emit,
      ) async {
    if (hasStopped) return;
    hasStopped = true;

    emit(state.copyWith(status: RecordingStatus.stopping));
    await _native.stopRecording(event.isLast);
    emit(state.copyWith(status: RecordingStatus.finished));
  }

  void onNewLevel(
      NewAudioLevelEvent event,
      Emitter<RecordingState> emit,
      ) {
    emit(state.copyWith(audioLevel: event.level));
  }

  void onNewChunk(
      NewChunkEvent event,
      Emitter<RecordingState> emit,
      ) {
    final chunk = RecordingChunk(
      id: DateTime.timestamp().toString(),
      sessionId: sessionId!,
      chunkNumber: event.chunkNumber,
      filePath: event.filePath,
      mimeType: 'audio/wav',
      status: ChunkStatus.pending,
      createdAt: DateTime.now(),
      isLast: event.isLast,
      retryCount: 0,
    );

    local.addChunk(chunk);

    final updated = List<Map<String, dynamic>>.from(state.receivedChunks)
      ..add({
        "filePath": event.filePath,
        "chunkNumber": event.chunkNumber,
        "isLast": event.isLast,
      });

    emit(state.copyWith(receivedChunks: updated));
  }

  void onRouteChanged(
      AudioRouteChangedEvent event,
      Emitter<RecordingState> emit,
      ) {
    emit(state.copyWith(route: event.route));
  }

  @override
  Future<void> close() {
    _levelSub?.cancel();
    _chunkSub?.cancel();
    _routeSub?.cancel();
    return super.close();
  }
}
