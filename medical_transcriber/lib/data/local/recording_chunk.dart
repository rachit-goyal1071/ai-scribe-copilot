import 'package:hive/hive.dart';
import 'package:medical_transcriber/data/local/chunk_status.dart';

part 'recording_chunk.g.dart';

@HiveType(typeId: 2)
class RecordingChunk extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String sessionId;

  @HiveField(2)
  int chunkNumber;

  @HiveField(3)
  String filePath;

  @HiveField(4)
  String mimeType;

  @HiveField(5)
  ChunkStatus status;

  @HiveField(6)
  int retryCount;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool isLast;

  RecordingChunk({
    required this.id,
    required this.sessionId,
    required this.chunkNumber,
    required this.filePath,
    required this.mimeType,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    required this.isLast,
  });
}