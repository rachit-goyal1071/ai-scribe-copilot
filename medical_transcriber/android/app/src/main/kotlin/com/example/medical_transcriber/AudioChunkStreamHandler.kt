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

    fun sendChunk(filePath: String, chunkNumber: Int, isLast: Boolean) {
        val map = hashMapOf<String, Any>(
            "filePath" to filePath,
            "chunkNumber" to chunkNumber,
            "isLast" to isLast
        )
        sink?.success(map)
    }
}

