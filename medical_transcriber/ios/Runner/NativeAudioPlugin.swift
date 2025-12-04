import Flutter
import AVFoundation

class NativeAudioPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    static let shared = NativeAudioPlugin()

    private var eventSink: FlutterEventSink?
    private var routeSink: FlutterEventSink?
    private var bufferSink: FlutterEventSink?

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = NativeAudioPlugin()

        let methodChannel = FlutterMethodChannel(name: "native_audio_channel", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let eventChannel = FlutterEventChannel(name: "native_audio_levels", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)

        let routeChannel = FlutterEventChannel(name: "native_audio_routes", binaryMessenger: registrar.messenger())
        routeChannel.setStreamHandler(instance)

        let bufferChannel = FlutterEventChannel(name: "native_audio_buffers", binaryMessenger: registrar.messenger())
        bufferChannel.setStreamHandler(instance)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startRecording":
            if let args = call.arguments as? [String: Any],
            let sessionId = args["sessionId"] as? String {
                try? NativeAudioManager.shared.startRecording(sessionId: sessionId)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing sessionId", details: nil))
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

    func emitAudioLevel(level: Float) {
        levelSink?(level)
    }

    func emitChunkEvent(fileUrl: URL, chunkNumber: Int, isLast: Bool) {
        let event: [String: Any] = [
            "filePath": fileUrl.absoluteString,
            "chunkNumber": chunkNumber,
            "isLast": isLast
        ]
        bufferSink?(event)
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
