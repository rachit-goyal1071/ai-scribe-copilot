package com.example.medical_transcriber

import android.app.*
import android.content.*
import android.media.*
import android.os.*
import androidx.core.app.NotificationCompat
import java.io.*
import java.nio.*
import kotlin.math.*
import android.bluetooth.BluetoothHeadset
import android.os.Binder
import android.os.IBinder
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.os.Build



class NativeAudioService: Service() {
    private val binder = LocalBinder()

    private lateinit var audioManager: AudioManager
    private lateinit var routeReceiver: BroadcastReceiver

    private var pcmBuffer = ByteArrayOutputStream()
    private val sampleRate = 16000
    private val channels = 1
    private val bitsPerSample = 16

    inner class LocalBinder : Binder() {
        fun getService(): NativeAudioService = this@NativeAudioService
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override  fun onCreate() {
        super.onCreate()
        startForegroundWithNotification()

        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        routeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == AudioManager.ACTION_HEADSET_PLUG) {
                    val state = intent.getIntExtra("state", -1)
                    when (state) {
                        0 -> NativeAudioPlugin.shared.emitRouteChange("unplugged")
                        1 -> NativeAudioPlugin.shared.emitRouteChange("wired_headset")
                    }
                }

                if (intent?.action == BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED) {
                    val state = intent.getIntExtra(BluetoothHeadset.EXTRA_STATE, -1)
                    when (state) {
                        BluetoothHeadset.STATE_CONNECTED ->
                            NativeAudioPlugin.instance.emitRouteChange("bluetooth_connected")

                        BluetoothHeadset.STATE_DISCONNECTED ->
                            NativeAudioPlugin.instance.emitRouteChange("bluetooth_disconnected")
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(AudioManager.ACTION_HEADSET_PLUG)
            addAction(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED)
        }

        registerReceiver(routeReceiver, filter)
    }


    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(routeReceiver)
    }


    private fun startForegroundWithNotification() {
        val channelId = "recording_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Recording",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentTitle("Recording in progress")
            .setContentText("MediNote is recording your audio")
            .build()

        startForeground(1, notification)
    }

    private var audioRecord: AudioRecord? = null
    private var recording: Boolean = false
    private var chunkNumber = 0
    private var sessionId: String = ""
    private var currentChunkStartTime: Long = 0L
    private var currentChunkFile: File? = null
    private var chunkLengthMs = 5000L

    fun startRecording(sessionId: String) {
        this.sessionId = sessionId
        chunkNumber = 0
        recording = true

        val sampleRate = 16000
        val channelConfig = AudioFormat.CHANNEL_IN_MONO
        val audioFormat = AudioFormat.ENCODING_PCM_16BIT
        val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRate,
            channelConfig,
            audioFormat,
            bufferSize
        )

        audioRecord?.startRecording()
        startChunk()
        startRecordingLoop(bufferSize)
    }

    private fun startChunk() {
        chunkNumber += 1
        currentChunkStartTime = System.currentTimeMillis()
        pcmBuffer.reset()
    }

    private fun startRecordingLoop(bufferSize: Int) {
        Thread {
            val buffer = ShortArray(bufferSize /2)
            while (recording && audioRecord?.recordingState == AudioRecord.RECORDSTATE_RECORDING) {
                val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                if (bytesRead > 0) {
                    writeBufferToChunk(buffer, bytesRead)
                    emitAudioLevel(buffer, bytesRead)
                    checkChunkRotation()
                }
            }
            stopInternal()
        }.start()
    }

    private fun stopInternal() {
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }

    private fun writeBufferToChunk(buffer: ShortArray, bytesRead: Int) {
        val bb = ByteBuffer.allocate(bytesRead * 2).order(ByteOrder.LITTLE_ENDIAN)
        for (i in 0 until bytesRead) {
            bb.putShort(buffer[i])
        }
        pcmBuffer.write(bb.array())
    }

    private fun checkChunkRotation() {
        val now = System.currentTimeMillis()
        if (now- currentChunkStartTime >= chunkLengthMs) {
            finalizeChunk(false)
            startChunk()
        }
    }

    private fun finalizeChunk(isLast: Boolean) {
        val pcmData = pcmBuffer.toByteArray()
        pcmBuffer.reset()

        if (pcmData.isEmpty()) return

        val dir = File(filesDir, "audio_chunks/$sessionId")
        dir.mkdirs()
        val wavFile = File(dir, "chunk_$chunkNumber.wav")

        writeWavFile(wavFile, pcmData)

        NativeAudioPlugin.instance.emitChunkEvent(
            mapOf(
                "filePath" to wavFile.absolutePath,
                "chunkNumber" to chunkNumber,
                "isLast" to isLast
            )
        )
    }


    private fun emitAudioLevel(buffer: ShortArray, read: Int) {
        var maxAmp = 0.0
        for (i in 0 until read) {
            maxAmp = max(maxAmp, abs(buffer[i].toDouble()))
        }
        val normalized = maxAmp / Short.MAX_VALUE
        NativeAudioPlugin.instance.emitAudioLevel(normalized)
    }

    private fun writeWavFile(outFile: File, pcmData: ByteArray) {
        val totalAudioLen = pcmData.size
        val totalDataLen = totalAudioLen + 36
        val byteRate = sampleRate * channels * bitsPerSample / 8

        val header = ByteArray(44)

        // RIFF header
        header[0] = 'R'.code.toByte()
        header[1] = 'I'.code.toByte()
        header[2] = 'F'.code.toByte()
        header[3] = 'F'.code.toByte()

        header[4] = (totalDataLen and 0xff).toByte()
        header[5] = ((totalDataLen shr 8) and 0xff).toByte()
        header[6] = ((totalDataLen shr 16) and 0xff).toByte()
        header[7] = ((totalDataLen shr 24) and 0xff).toByte()

        header[8] = 'W'.code.toByte()
        header[9] = 'A'.code.toByte()
        header[10] = 'V'.code.toByte()
        header[11] = 'E'.code.toByte()

        // fmt chunk
        header[12] = 'f'.code.toByte()
        header[13] = 'm'.code.toByte()
        header[14] = 't'.code.toByte()
        header[15] = ' '.code.toByte()

        header[16] = 16
        header[17] = 0
        header[18] = 0
        header[19] = 0

        header[20] = 1
        header[21] = 0

        header[22] = channels.toByte()
        header[23] = 0

        header[24] = (sampleRate and 0xff).toByte()
        header[25] = ((sampleRate shr 8) and 0xff).toByte()
        header[26] = ((sampleRate shr 16) and 0xff).toByte()
        header[27] = ((sampleRate shr 24) and 0xff).toByte()

        header[28] = (byteRate and 0xff).toByte()
        header[29] = ((byteRate shr 8) and 0xff).toByte()
        header[30] = ((byteRate shr 16) and 0xff).toByte()
        header[31] = ((byteRate shr 24) and 0xff).toByte()

        header[32] = ((channels * bitsPerSample) / 8).toByte()
        header[33] = 0
        header[34] = bitsPerSample.toByte()
        header[35] = 0

        header[36] = 'd'.code.toByte()
        header[37] = 'a'.code.toByte()
        header[38] = 't'.code.toByte()
        header[39] = 'a'.code.toByte()

        header[40] = (totalAudioLen and 0xff).toByte()
        header[41] = ((totalAudioLen shr 8) and 0xff).toByte()
        header[42] = ((totalAudioLen shr 16) and 0xff).toByte()
        header[43] = ((totalAudioLen shr 24) and 0xff).toByte()

        FileOutputStream(outFile).use { fos ->
            fos.write(header, 0, 44)
            fos.write(pcmData)
        }
    }

}