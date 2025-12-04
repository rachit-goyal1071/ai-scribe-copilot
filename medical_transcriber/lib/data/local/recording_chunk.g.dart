// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_chunk.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordingChunkAdapter extends TypeAdapter<RecordingChunk> {
  @override
  final int typeId = 2;

  @override
  RecordingChunk read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordingChunk(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      chunkNumber: fields[2] as int,
      filePath: fields[3] as String,
      mimeType: fields[4] as String,
      status: fields[5] as ChunkStatus,
      retryCount: fields[6] as int,
      createdAt: fields[7] as DateTime,
      isLast: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RecordingChunk obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.chunkNumber)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.mimeType)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.retryCount)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isLast);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingChunkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
