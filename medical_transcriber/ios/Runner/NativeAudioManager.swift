import Flutter
import AVFoundation

class NativeAudioManager: NSObject {

    static let shared = NativeAudioManager()

    // MARK: - Audio State
    private let session = AVAudioSession.sharedInstance()
    private var engine: AVAudioEngine?
    private var file: AVAudioFile?

    private var sessionId: String = ""
    private var chunkNumber: Int = 0
    private var chunkStartTime: TimeInterval = 0
    private let chunkLengthSec: TimeInterval = 5.0

    private var isPaused: Bool = false


    // MARK: - Session Setup
    func configureSession() throws {
        try session.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: [.allowBluetooth, .defaultToSpeaker]
        )
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        // Optional gain control
        if session.isInputGainSettable {
            try session.setInputGain(0.9)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: session
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: session
        )
    }


    // MARK: - Interruption Handling
    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let rawType = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: rawType)
        else { return }

        switch type {
        case .began:
            pauseRecording()
        case .ended:
            resumeRecording()
        default:
            break
        }
    }


    // MARK: - Route Changes (Bluetooth, Wired)
    @objc private func handleRouteChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let rawReason = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: rawReason)
        else { return }

        switch reason {
        case .oldDeviceUnavailable:
            NativeAudioPlugin.emitRouteChange("unplugged")

        case .newDeviceAvailable:
            let input = session.currentRoute.inputs.first?.portType
            switch input {
            case .bluetoothHFP, .bluetoothA2DP, .bluetoothLE:
                NativeAudioPlugin.emitRouteChange("bluetooth")

            case .headsetMic:
                NativeAudioPlugin.emitRouteChange("wired_headset")

            default:
                NativeAudioPlugin.emitRouteChange("other")
            }

        default:
            NativeAudioPlugin.emitRouteChange("other")
        }
    }


    // MARK: - Start Recording
    func startRecording(sessionId: String) throws {
        self.sessionId = sessionId

        try configureSession()

        engine = AVAudioEngine()
        guard let engine = engine else { return }

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        chunkNumber = 0
        startNewChunk(format: format)

        inputNode.installTap(onBus: 0, bufferSize: 2048, format: format) { [weak self] buffer, time in
            self?.processBuffer(buffer)
        }

        engine.prepare()
        try engine.start()
    }


    // MARK: - Chunk Handling
    private func startNewChunk(format: AVAudioFormat) {
        chunkNumber += 1
        chunkStartTime = CFAbsoluteTimeGetCurrent()

        let baseDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let sessionDir = baseDir.appendingPathComponent("audio_chunks/\(sessionId)", isDirectory: true)

        try? FileManager.default.createDirectory(at: sessionDir, withIntermediateDirectories: true)

        let fileURL = sessionDir.appendingPathComponent("chunk_\(chunkNumber).wav")

        file = try? AVAudioFile(forWriting: fileURL, settings: format.settings)
    }


    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let file = file else { return }
        if isPaused { return }

        do {
            try file.write(from: buffer)
        } catch {
            print("Error writing buffer: \(error)")
        }

        emitLevel(buffer)
        rotateChunkIfNeeded()
    }


    private func rotateChunkIfNeeded() {
        let now = CFAbsoluteTimeGetCurrent()
        if now - chunkStartTime >= chunkLengthSec {
            finalizeChunk(isLast: false)

            if let engine = engine {
                let format = engine.inputNode.outputFormat(forBus: 0)
                startNewChunk(format: format)
            }
        }
    }


    private func finalizeChunk(isLast: Bool) {
        guard let f = file else { return }

        let url = f.url
        self.file = nil

        NativeAudioPlugin.emitChunkEvent(url: url, chunkNumber: chunkNumber, isLast: isLast)
    }


    // MARK: - Audio Level Meter
    private func emitLevel(_ buffer: AVAudioPCMBuffer) {
        guard let data = buffer.floatChannelData?[0] else { return }

        let frameCount = Int(buffer.frameLength)
        var maxAmp: Float = 0

        for i in 0..<frameCount {
            maxAmp = max(maxAmp, abs(data[i]))
        }

        NativeAudioPlugin.emitAudioLevel(maxAmp)
    }


    // MARK: - Pause/Resume/Stop

    func pauseRecording() {
        guard let engine = engine else { return }
        engine.pause()
        isPaused = true
    }

    func resumeRecording() {
        guard let engine = engine else { return }
        isPaused = false
        try? engine.start()
    }

    func stopRecording(isLast: Bool) {
        guard let engine = engine else { return }

        engine.inputNode.removeTap(onBus: 0)
        engine.stop()

        finalizeChunk(isLast: isLast)
        try? session.setActive(false)
    }
}
