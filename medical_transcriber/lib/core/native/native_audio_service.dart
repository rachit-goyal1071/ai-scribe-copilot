import 'package:flutter/services.dart';

class NativeAudioService {
  static final NativeAudioService instance = NativeAudioService.internal();
  factory NativeAudioService() => instance;
  NativeAudioService.internal();

  static const MethodChannel methodChannel = MethodChannel("native_audio_channel");
  static const EventChannel levelChannel = EventChannel("native_audio_levels");
  static const EventChannel routeChannel = EventChannel("native_audio_routes");
  static const EventChannel bufferChannel = EventChannel("native_audio_buffers");

  Stream<double>? levelStream;
  Stream<String>? routeStream;
  Stream<Map<String, dynamic>>? chunkStream;

  Stream<double> audioLevels() {
    return levelStream ??= levelChannel.receiveBroadcastStream().map((event) => (event as num).toDouble());
  }

  Stream<String> audioRoutes() {
    return routeStream ??= routeChannel.receiveBroadcastStream().map((event) => event as String);
  }

  Stream<Map<String, dynamic>> audioChunks() {
    return chunkStream ??= bufferChannel.receiveBroadcastStream().map((event) => Map<String, dynamic>.from(event as Map));
  }

  Future<void> startRecording(String sessionId) async {
    await methodChannel.invokeMethod("startRecording", {"sessionId": sessionId});
  }

  Future<void> pauseRecording() async {
    await methodChannel.invokeMethod("pauseRecording");
  }

  Future<void> resumeRecording() async {
    await methodChannel.invokeMethod("resumeRecording");
  }

  Future<void> stopRecording(bool isLast) async {
    await methodChannel.invokeMethod("stopRecording", {"isLast": isLast});
  }
}