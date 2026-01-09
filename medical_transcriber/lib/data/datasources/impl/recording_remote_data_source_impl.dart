import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medical_transcriber/data/datasources/recording_remote_data_source.dart';

import '../../../core/network/app_dio.dart';

class RecordingRemoteDataSourceImpl implements RecordingRemoteDataSource {
  final _dio = AppDio();

  @override
  Future<String> createSession({
    required String patientId,
    required String userId,
    required String patientName,
    required String status,
    required String startTime,
    required String templateId,
  }) async {
    final response = await _dio.client.post(
      "/v1/upload-session",
      data: {
        "patientId": patientId,
        "userId": userId,
        "patientName": patientName,
        "status": status,
        "startTime": startTime,
        "templateId": templateId
      });
    return response.data["id"].toString();
  }

  @override
  Future<Map<String, dynamic>> getPresignedUrl(
      String sessionId,
      int chunkNumber,
      String mimeType,
      ) async {
    final response = await _dio.client.post(
      "/v1/get-presigned-url",
      data: {
        "sessionId": sessionId,
        "chunkNumber": chunkNumber,
        "mimeType": mimeType,
      });
    return response.data;
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
    required String model,
  }) async {
    final response = await _dio.client.post(
      "/v1/notify-chunk-uploaded",
      data: {
        "sessionId": sessionId,
        "gcsPath": gcsPath,
        "chunkNumber": chunkNumber,
        "isLast": isLast,
        "totalChunksClient": totalChunksClient,
        "publicUrl": publicUrl,
        "mimeType": mimeType,
        "selectedTemplate": selectedTemplate,
        "selectedTemplateId": selectedTemplateId,
        "model": model
      });
    if (kDebugMode) {
      debugPrint("Chunk upload notified: ${response.data}");
    }
  }
}