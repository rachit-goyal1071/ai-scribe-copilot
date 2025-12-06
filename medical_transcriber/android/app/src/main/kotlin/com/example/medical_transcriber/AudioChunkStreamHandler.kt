package com.example.medical_transcriber

import io.flutter.plugin.common.EventChannel

object AudioChunkStreamHandler : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun sendChunk(payload: Map<String, Any>) {
        sink?.success(payload)
    }
}


