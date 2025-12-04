import 'package:medical_transcriber/data/datasources/recording_remote_data_source.dart';
import 'package:medical_transcriber/domain/repositories/recording_repository.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingRemoteDataSource remote;

  RecordingRepositoryImpl(this.remote);

  @override
  Future<String> createSession({
    required String patientId,
    required String userId,
    required String patientName,
    required String status,
    required String startTime,
    required String templateId
  }) {
    return remote.createSession(
      patientId: patientId,
      userId: userId,
      patientName: patientName,
      status: status,
      startTime: startTime,
      templateId: templateId
    );
  }

  @override
  Future<Map<String, dynamic>> getPresignedUrl(String sessionId, int chunkNumber, String mimeType) {
    return remote.getPresignedUrl(sessionId, chunkNumber, mimeType);
  }

  @override
  Future<void> notifyChunkUploaded({
    required String sessionId,
    required String gcsPath,
    required int chunkNumber,
    required bool isLast,
    required int totalChunksClient,
    required String publicUrl,
    required String mimeType,
    required String selectedTemplate,
    required String selectedTemplateId,
    required String model
  }) {
    return remote.notifyChunkUploaded(
      sessionId: sessionId,
      gcsPath: gcsPath,
      chunkNumber: chunkNumber,
      isLast: isLast,
      totalChunksClient: totalChunksClient,
      publicUrl: publicUrl,
      mimeType: mimeType,
      selectedTemplate: selectedTemplate,
      selectedTemplateId: selectedTemplateId,
      model: model
    );
  }
}