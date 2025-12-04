import AVFoundation

class ChunkedAudioRecorder {
    private let session = AVAudioSession.sharedInstance()
    private let engine = AVAudioEngine()
    private var file: AVAudioFile?
    private var sessionId: String
    private var chunkNumber = 0
    private let chunkLength: TimeInterval = 5.0
    private var chunkStartTime: TimeInterval = 0

    init(sessionId: String) {
        self.sessionId = sessionId
    }

    func configureSession() throws {
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetooth, .defaultToSpeaker])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    func start() {
        do {
            try configureSession()
        } catch {
            print("AVAudioSession error \(error)")
            return
        }

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        startNewChunk(format: format)

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            self?.process(buffer: buffer, time: time)
        }

        engine.prepare()
        do {
            try engine.start()
        } catch {
            print("Engine start failed: \(error)")
        }
    }

    private func startNewChunk(format: AVAudioFormat) {
        chunkNumber += 1
        chunkStartTime = CFAbsoluteTimeGetCurrent()

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("audio_chunks/\(sessionId)", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let url = dir.appendingPathComponent("chunk_\(chunkNumber).wav")
        do {
            file = try AVAudioFile(forWriting: url, settings: format.settings)
        } catch {
            print("Cannot create AVAudioFile: \(error)")
        }
    }

    private func process(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        guard let file = file else { return }

        do {
            try file.write(from: buffer)
        } catch {
            print("Write error: \(error)")
        }

        emitLevel(buffer: buffer)
        rotateChunkIfNeeded()
    }

    private func rotateChunkIfNeeded() {
        let now = CFAbsoluteTimeGetCurrent()
        if now - chunkStartTime >= chunkLength {
            finalizeChunk(isLast: false)
            let format = engine.inputNode.outputFormat(forBus: 0)
            startNewChunk(format: format)
        }
    }

    private func emitLevel(buffer: AVAudioPCMBuffer) {
        guard let chanData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        var maxAmp: Float = 0
        for i in 0..<frameLength {
            maxAmp = max(maxAmp, fabsf(chanData[i]))
        }
        NativeAudioPlugin.sendLevel(Double(maxAmp))
    }

    private func finalizeChunk(isLast: Bool) {
        guard let f = file else { return }
        let url = f.url
        file = nil
        NativeAudioPlugin.sendChunk(filePath: url.path, chunkNumber: chunkNumber, isLast: isLast)
    }

    func pause() {
        engine.pause()
    }

    func resume() {
        do {
            try engine.start()
        } catch {
            print("Resume error: \(error)")
        }
    }

    func stop(isLast: Bool) {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        finalizeChunk(isLast: isLast)
        try? session.setActive(false)
    }
}
