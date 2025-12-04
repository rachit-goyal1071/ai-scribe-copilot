// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chunk_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChunkStatusAdapter extends TypeAdapter<ChunkStatus> {
  @override
  final int typeId = 1;

  @override
  ChunkStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChunkStatus.pending;
      case 1:
        return ChunkStatus.uploading;
      case 2:
        return ChunkStatus.uploaded;
      case 3:
        return ChunkStatus.failed;
      case 4:
        return ChunkStatus.giveUp;
      default:
        return ChunkStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ChunkStatus obj) {
    switch (obj) {
      case ChunkStatus.pending:
        writer.writeByte(0);
        break;
      case ChunkStatus.uploading:
        writer.writeByte(1);
        break;
      case ChunkStatus.uploaded:
        writer.writeByte(2);
        break;
      case ChunkStatus.failed:
        writer.writeByte(3);
        break;
      case ChunkStatus.giveUp:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChunkStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
