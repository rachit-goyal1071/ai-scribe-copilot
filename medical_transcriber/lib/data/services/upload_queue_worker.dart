import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:medical_transcriber/data/local/chunk_local_data_source.dart';
import 'package:medical_transcriber/domain/repositories/recording_repository.dart';

import '../local/chunk_status.dart';
import '../local/recording_chunk.dart';

class UploadQueueWorker {
  final ChunkLocalDataSource local;
  final RecordingRepository recordingRepo;
  final Dio dio;

  bool running = false;
  Timer? timer;

  UploadQueueWorker({
    required this.local,
    required this.recordingRepo,
    Dio? dioClient,
  }) : dio = dioClient ?? Dio();

  void start() {
    if (running) return;
    running = true;

    timer = Timer.periodic(const Duration(seconds: 5), (_) async{
      await processPending();
    });
  }

  void stop() {
    running = false;
    timer?.cancel();
    timer = null;
  }

  bool isProcessing = false;

  Future<void> processPending() async {
    if (!running || isProcessing) return;

    isProcessing = true;
    final chunks = local.getPendingChunks();

    for (final chunk in chunks) {
      await uploadChunk(chunk);
    }

    isProcessing = false;
  }

  Future<void> uploadChunk(RecordingChunk chunk) async {
    try {
      chunk.status = ChunkStatus.uploading;
      await local.updateChunk(chunk);

      final presignedUrl = await recordingRepo.getPresignedUrl(
        chunk.sessionId,
        chunk.chunkNumber,
        chunk.mimeType,
      );

      print(presignedUrl);
      final uploadUrl = presignedUrl['url'];
      final publicUrl = presignedUrl['publicUrl'];
      final gcsPath = presignedUrl['gcsPath'];
      
      final bytes = await File(chunk.filePath).readAsBytes();

      final response = await dio.put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {"Content-Type": chunk.mimeType},
        ),
      );
      print(response.statusCode);

      await recordingRepo.notifyChunkUploaded(
        sessionId: chunk.sessionId,
        gcsPath: gcsPath,
        chunkNumber: chunk.chunkNumber,
        isLast: chunk.isLast,
        totalChunksClient: chunk.chunkNumber,
        publicUrl: publicUrl,
        mimeType: chunk.mimeType,
        selectedTemplate: "default",
        selectedTemplateId: "temp_default",
        model: "fast",
      );

      chunk.status = ChunkStatus.uploaded;
      await local.updateChunk(chunk);

    } catch (e) {
      chunk.retryCount++;
      print("Upload failed for chunk ${chunk.id}: $e");
      if (chunk.retryCount >= 3) {
        chunk.status = ChunkStatus.giveUp;
      } else {
        chunk.status = ChunkStatus.failed;
      }

      await local.updateChunk(chunk);
    }
  }
}