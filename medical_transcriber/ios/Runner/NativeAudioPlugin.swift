import Flutter
import AVFoundation

@objc(NativeAudioPlugin)
class NativeAudioPlugin: NSObject, FlutterPlugin {

    // EventChannel sinks
    static var audioLevelSink: FlutterEventSink?
    static var routeSink: FlutterEventSink?
    static var chunkSink: FlutterEventSink?

    // Required registration entry point
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = NativeAudioPlugin()

        // Method channel
        let methodChannel = FlutterMethodChannel(
            name: "native_audio_channel",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        // Audio level stream
        let levelChannel = FlutterEventChannel(
            name: "native_audio_levels",
            binaryMessenger: registrar.messenger()
        )
        levelChannel.setStreamHandler(AudioLevelStreamHandler())

        // Route change stream
        let routeChannel = FlutterEventChannel(
            name: "native_audio_routes",
            binaryMessenger: registrar.messenger()
        )
        routeChannel.setStreamHandler(AudioRouteStreamHandler())

        // Chunk events stream
        let bufferChannel = FlutterEventChannel(
            name: "native_audio_buffers",
            binaryMessenger: registrar.messenger()
        )
        bufferChannel.setStreamHandler(AudioChunkStreamHandler())
    }

    // Handle method calls from Dart
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startRecording":
            if let args = call.arguments as? [String: Any],
            let sessionId = args["sessionId"] as? String {
                do {
                    try NativeAudioManager.shared.startRecording(sessionId: sessionId)
                    result(nil)
                } catch {
                    result(
                        FlutterError(
                            code: "START_ERROR",
                            message: error.localizedDescription,
                            details: nil
                        )
                    )
                }
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing sessionId",
                        details: nil
                    )
                )
            }

        case "pauseRecording":
            NativeAudioManager.shared.pauseRecording()
            result(nil)

        case "resumeRecording":
            NativeAudioManager.shared.resumeRecording()
            result(nil)

        case "stopRecording":
            if let args = call.arguments as? [String: Any],
            let isLast = args["isLast"] as? Bool {
                NativeAudioManager.shared.stopRecording(isLast: isLast)
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Helpers used by NativeAudioManager / ChunkedAudioRecorder

    /// Called from NativeAudioManager.emitLevel(...)
    static func emitAudioLevel(_ level: Float) {
        // Flutter can handle Double/NSNumber
        audioLevelSink?(Double(level))
    }

    /// Called from NativeAudioManager.handleRouteChange(...)
    static func emitRouteChange(_ route: String) {
        routeSink?(["route": route])
    }

    /// Called from NativeAudioManager.finalizeChunk(...)
    static func emitChunkEvent(url: URL, chunkNumber: Int, isLast: Bool) {
        let payload: [String: Any] = [
            "filePath": url.path,        // or url.absoluteString if you prefer
            "chunkNumber": chunkNumber,
            "isLast": isLast
        ]
        chunkSink?(payload)
    }

    // Legacy names used by ChunkedAudioRecorder (so it compiles without change)
    static func sendLevel(_ value: Double) {
        audioLevelSink?(value)
    }

    static func sendChunk(filePath: String, chunkNumber: Int, isLast: Bool) {
        let payload: [String: Any] = [
            "filePath": filePath,
            "chunkNumber": chunkNumber,
            "isLast": isLast
        ]
        chunkSink?(payload)
    }
}

class AudioLevelStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        NativeAudioPlugin.audioLevelSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NativeAudioPlugin.audioLevelSink = nil
        return nil
    }
}

class AudioChunkStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        NativeAudioPlugin.chunkSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NativeAudioPlugin.chunkSink = nil
        return nil
    }
}

class AudioRouteStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        NativeAudioPlugin.routeSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NativeAudioPlugin.routeSink = nil
        return nil
    }
}
