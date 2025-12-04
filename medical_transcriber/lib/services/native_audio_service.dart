// import 'package:flutter/services.dart';
//
// class NativeAudioService {
//   static const methodChannel = MethodChannel("native_audio_channel");
//   static const levelChannel = EventChannel("native_audio_levels");
//   static const routeChannel = EventChannel("native_audio_routes");
//   static const bufferChannel = EventChannel("native_audio_buffers");
//
//   static final NativeAudioService instance = NativeAudioService.internal();
//   factory NativeAudioService() => instance;
//   NativeAudioService.internal();
//
//   Stream<double> get audioLevelStream => levelChannel.receiveBroadcastStream().map((event) => event as double);
//
//   Stream<String> get routeChangesStream => routeChannel.receiveBroadcastStream().map((event) => event as String);
//
//   Stream<List<int>> get bufferStream => bufferChannel.receiveBroadcastStream()
//       .map((event) => (event as List<dynamic>).cast<int>());
//
//   Future<void> startRecording(String sessionId) async {
//     print("Starting recording for session: $sessionId");
//     await methodChannel.invokeMethod("startRecording", {"sessionId": sessionId});
//   }
//
//   Future<void> pauseRecording(String sessionId) async {
//     await methodChannel.invokeMethod("pauseRecording");
//   }
//
//   Future<void> resumeRecording(String sessionId) async {
//     await methodChannel.invokeMethod("resumeRecording");
//   }
//
//   Future<void> stopRecording( bool isLast) async {
//     await methodChannel.invokeMethod("stopRecording", {
//       "isLast": isLast
//     });
//   }
//
//
// }