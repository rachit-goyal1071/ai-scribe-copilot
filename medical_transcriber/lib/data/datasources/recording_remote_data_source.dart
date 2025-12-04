abstract class RecordingRemoteDataSource {
  Future<String> createSession({
    required String patientId,
    required String userId,
    required String patientName,
    required String status,
    required String startTime,
    required String templateId,
  });

  Future<Map<String, dynamic>> getPresignedUrl(
      String sessionId,
      int chunkNumber,
      String mimeType,
      );

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
    required String model,
  });
}
