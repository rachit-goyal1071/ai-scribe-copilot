package com.example.medical_transcriber

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import kotlinx.coroutines.*
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.log10
import kotlin.math.sqrt

class ChunkAudioRecorder(
    private val context: Context,
    private val sessionId: String
) {
    private val scope = CoroutineScope(Dispatchers.IO)
    private var recordingJob: Job? = null

    private var audioRecord: AudioRecord? = null
    private var currentStream: FileOutputStream? = null

    @Volatile private var isRecording = false
    @Volatile private var isPaused = false

    private var chunkNumber = 1
    private val chunkDurationMs = 5000L

    private val sampleRate = 16000
    private val channelConfig = AudioFormat.CHANNEL_IN_MONO
    private val encoding = AudioFormat.ENCODING_PCM_16BIT
    private val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, encoding)

    private lateinit var currentChunkFile: File
    private val pcmBuffer = ByteArrayOutputStream()

    fun start() {
        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRate,
            channelConfig,
            encoding,
            bufferSize
        )

        isRecording = true
        isPaused = false
        chunkNumber = 1
        pcmBuffer.reset()

        audioRecord?.startRecording()
        startNewChunk()

        recordingJob = scope.launch { readAudioLoop() }
    }

    fun pause() { isPaused = true }
    fun resume() { isPaused = false }

    suspend fun stop(isLast: Boolean) {
        isRecording = false

        // Wait for loop thread to exit
        recordingJob?.join()
        recordingJob = null

        try {
            finalizeWavChunk()

            if (isLast) {
                NativeAudioPlugin.instance.emitChunkEvent(
                    mapOf(
                        "filePath" to currentChunkFile.absolutePath,
                        "chunkNumber" to chunkNumber,
                        "isLast" to true
                    )
                )
            }
        } catch (_: Exception) { }
        print("Recorder STOP: file=${currentChunkFile.name}, chunkNumber=$chunkNumber")
        currentStream?.close()
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }

    private fun normalizeDb(db: Double): Double {
        val minDb = -60.0
        val maxDb = -5.0
        val clipped = db.coerceIn(minDb, maxDb)
        return (clipped - minDb) / (maxDb - minDb)
    }

    private suspend fun readAudioLoop() {
        val buffer = ByteArray(bufferSize)
        var lastSplitTime = System.currentTimeMillis()

        while (isRecording) {

            if (isPaused) {
                delay(20)
                continue
            }

            val count = audioRecord?.read(buffer, 0, buffer.size) ?: 0
            if (count <= 0) continue

            // Write into file output stream
            currentStream?.write(buffer, 0, count)

            // Store into PCM buffer for full WAV rewrite
            pcmBuffer.write(buffer, 0, count)

            // Send audio level
            val level = calculateRms(buffer, count)
            val normalized = normalizeDb(level)
            NativeAudioPlugin.instance.emitAudioLevel(normalized)

            // Split chunks
            val now = System.currentTimeMillis()
            if (now - lastSplitTime >= chunkDurationMs) {
                finalizeWavChunk()

                NativeAudioPlugin.instance.emitChunkEvent(
                    mapOf(
                        "filePath" to currentChunkFile.absolutePath,
                        "chunkNumber" to chunkNumber,
                        "isLast" to false
                    )
                )

                chunkNumber++
                startNewChunk()
                lastSplitTime = now
            }
        }
    }

    private fun startNewChunk() {
        val root = File(context.getExternalFilesDir(null), "sessions/$sessionId/")
        if (!root.exists()) root.mkdirs()

        currentChunkFile = File(root, "chunk_$chunkNumber.wav")
        pcmBuffer.reset()

        currentStream = FileOutputStream(currentChunkFile)
        writePlaceholderHeader()
    }

    private fun writePlaceholderHeader() {
        val header = ByteArray(44)
        currentStream?.write(header)
    }

    private fun finalizeWavChunk() {
        val pcmData = pcmBuffer.toByteArray()
        if (pcmData.isEmpty()) return

        currentStream?.flush()
        currentStream?.close()

        val totalAudioLen = pcmData.size.toLong()
        val totalDataLen = totalAudioLen + 36

        FileOutputStream(currentChunkFile, false).use { out ->
            writeWavHeader(out, totalAudioLen, totalDataLen)
            out.write(pcmData)
        }

        pcmBuffer.reset()
    }

    private fun writeWavHeader(out: FileOutputStream, audioLen: Long, dataLen: Long) {
        val channels = 1
        val byteRate = sampleRate * 2 * channels

        val header = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN)
        header.put("RIFF".toByteArray())
        header.putInt(dataLen.toInt())
        header.put("WAVE".toByteArray())
        header.put("fmt ".toByteArray())
        header.putInt(16)
        header.putShort(1)
        header.putShort(channels.toShort())
        header.putInt(sampleRate)
        header.putInt(byteRate)
        header.putShort((2 * channels).toShort())
        header.putShort(16)
        header.put("data".toByteArray())
        header.putInt(audioLen.toInt())

        out.write(header.array())
    }

    private fun calculateRms(data: ByteArray, valid: Int): Double {
        var sumSq = 0.0
        val samples = valid / 2
        if (samples == 0) return -120.0

        for (i in 0 until samples) {
            val lo = data[i * 2].toInt() and 0xff
            val hi = data[i * 2 + 1].toInt() shl 8
            val sample = hi or lo
            sumSq += sample * sample
        }

        val rms = sqrt(sumSq / samples)
        return 20 * log10(rms / 32767.0 + 1e-6)
    }
}