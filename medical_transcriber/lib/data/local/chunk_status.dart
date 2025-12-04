import 'package:hive/hive.dart';

part 'chunk_status.g.dart';

@HiveType(typeId: 1)
enum ChunkStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  uploading,

  @HiveField(2)
  uploaded,

  @HiveField(3)
  failed,

  @HiveField(4)
  giveUp,
}