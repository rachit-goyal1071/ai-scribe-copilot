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

    private var audioRecord: AudioRecord? = null
    private var recordingJob: Job? = null

    @Volatile
    private var isRecording = false
    @Volatile
    private var isPaused = false

    private var chunkNumber = 1

    private val sampleRate = 16000
    private val channelConfig = AudioFormat.CHANNEL_IN_MONO
    private val encoding = AudioFormat.ENCODING_PCM_16BIT
    private val chunkDurationMs = 5000L

    private val bufferSize = AudioRecord.getMinBufferSize(
        sampleRate,
        channelConfig,
        encoding
    )

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

        // keep the job so we can join it on stop()
        recordingJob = scope.launch { readAudioLoop() }
    }

    fun pause() {
        isPaused = true
    }

    fun resume() {
        isPaused = false
    }

    suspend fun stop(isLast: Boolean) {
        // signal loop to finish
        isRecording = false

        // wait for the loop to exit so no more writes happen
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
        } catch (_: Exception) {
        }

        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }

    private suspend fun readAudioLoop() {
        val buffer = ByteArray(bufferSize)
        var lastSplitTime = System.currentTimeMillis()

        while (isRecording) {
            if (isPaused) {
                delay(50)
                continue
            }

            val read = audioRecord?.read(buffer, 0, buffer.size) ?: 0
            if (read <= 0) continue

            // write to in-memory buffer (no open file stream here)
            pcmBuffer.write(buffer, 0, read)

            // audio level for UI
            val level = calculateRms(buffer, read)
            NativeAudioPlugin.instance.emitAudioLevel(level)

            val now = System.currentTimeMillis()
            if (now - lastSplitTime >= chunkDurationMs) {
                // finalize current chunk to disk
                finalizeWavChunk()

                // notify Flutter
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
    }

    private fun finalizeWavChunk() {
        val pcmData = pcmBuffer.toByteArray()
        if (pcmData.isEmpty()) return

        val totalAudioLen = pcmData.size.toLong()
        val totalDataLen = totalAudioLen + 36

        FileOutputStream(currentChunkFile, false).use { out ->
            writeWavHeader(out, totalAudioLen, totalDataLen)
            out.write(pcmData)
        }

        pcmBuffer.reset()
    }

    private fun writeWavHeader(
        out: FileOutputStream,
        audioLen: Long,
        dataLen: Long
    ) {
        val channels = 1
        val byteRate = sampleRate * 2 * channels

        val header = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN)

        header.put("RIFF".toByteArray())
        header.putInt(dataLen.toInt())
        header.put("WAVE".toByteArray())
        header.put("fmt ".toByteArray())
        header.putInt(16)                 // Subchunk1Size for PCM
        header.putShort(1)                // AudioFormat = PCM
        header.putShort(channels.toShort())
        header.putInt(sampleRate)
        header.putInt(byteRate)
        header.putShort((2 * channels).toShort()) // BlockAlign
        header.putShort(16)               // BitsPerSample
        header.put("data".toByteArray())
        header.putInt(audioLen.toInt())

        out.write(header.array())
    }

    private fun calculateRms(data: ByteArray, validBytes: Int): Double {
        var sumSq = 0.0
        val samples = validBytes / 2
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
