package com.example.medical_transcriber

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.BinaryMessenger
import java.io.File
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class NativeAudioPlugin(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    companion object {
        lateinit var instance: NativeAudioPlugin
        lateinit var shared: NativeAudioPlugin
    }

    private val methodChannel = MethodChannel(messenger, "native_audio_channel")
    private val levelChannel = EventChannel(messenger, "native_audio_levels")
    private val routeChannel = EventChannel(messenger, "native_audio_routes")
    private val bufferChannel = EventChannel(messenger, "native_audio_buffers")

    private var levelSink: EventChannel.EventSink? = null
    private var routeSink: EventChannel.EventSink? = null
    private var bufferSink: EventChannel.EventSink? = null

    private val pluginScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    private var recorder: ChunkAudioRecorder? = null

    init {
        instance = this

        methodChannel.setMethodCallHandler(this)

        levelChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                levelSink = events
            }

            override fun onCancel(arguments: Any?) {
                levelSink = null
            }
        })

        routeChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                routeSink = events
            }

            override fun onCancel(arguments: Any?) {
                routeSink = null
            }
        })

        bufferChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                bufferSink = events
            }

            override fun onCancel(arguments: Any?) {
                bufferSink = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startRecording" -> {
                val sessionId = call.argument<String>("sessionId")!!
                recorder = ChunkAudioRecorder(context, sessionId)
                recorder?.start()
                result.success(null)
            }

            "pauseRecording" -> {
                recorder?.pause()
                result.success(null)
            }

            "resumeRecording" -> {
                recorder?.resume()
                result.success(null)
            }

            "stopRecording" -> {
                val isLast = call.argument<Boolean>("isLast") ?: true
                pluginScope.launch {
                    recorder?.stop(isLast)
                    result.success(null)
                }
            }

            else -> result.notImplemented()
        }
    }

    fun emitAudioLevel(level: Double) {
        Handler(Looper.getMainLooper()).post {
            levelSink?.success(level)
        }
    }


    fun emitRouteChange(route: String) {
        Handler(Looper.getMainLooper()).post {
            routeSink?.success(route)
        }
    }

    fun emitChunkEvent(payload: Map<String, Any>) {
        Handler(Looper.getMainLooper()).post {
            bufferSink?.success(payload)
        }
    }
}
