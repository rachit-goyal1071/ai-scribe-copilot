import 'package:hive/hive.dart';
import 'package:medical_transcriber/data/local/chunk_status.dart';
import 'package:medical_transcriber/data/local/recording_chunk.dart';

class ChunkLocalDataSource {
  static const boxName = "recording_chunks";

  Box<RecordingChunk> get box => Hive.box<RecordingChunk>(boxName);

  Future<void> addChunk(RecordingChunk chunk) async {
    await box.put(chunk.id, chunk);
  }

  List<RecordingChunk> getPendingChunks() {
    return box.values
        .where((c) => c.status == ChunkStatus.pending ||
        (c.status == ChunkStatus.failed && c.retryCount < 3))
        .toList()
        ..sort((a,b) {
          final bySession = a.sessionId.compareTo(b.sessionId);
          if (bySession != 0) {
            return bySession;
          }
          return a.chunkNumber.compareTo(b.chunkNumber);
        });
  }

  Future<void> updateChunk(RecordingChunk chunk) async {
    await box.put(chunk.id, chunk);
  }

  Future<void> deleteChunk(String chunkId) async {
    await box.delete(chunkId);
  }

  Future<void> markUploading(String id) async {
    final c = box.get(id);
    if (c == null) return;
    c.status = ChunkStatus.uploading;
    await c.save();
  }

  Future<void> markUploaded(String id) async {
    final c = box.get(id);
    if (c == null) return;
    c.status = ChunkStatus.uploaded;
    await c.save();
  }

  Future<void> markFailed(String id) async {
    final c = box.get(id);
    if (c == null) return;
    c.status = ChunkStatus.failed;
    c.retryCount += 1;
    await c.save();
  }
}