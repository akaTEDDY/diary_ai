package com.example.diary_ai

import io.flutter.plugin.common.EventChannel

object EventStreamHandler : EventChannel.StreamHandler {
        private var eventSink: EventChannel.EventSink? = null
        private val eventQueue: MutableList<String> = mutableListOf()

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events

                // 실행 내역 기록
                DataManager.addExecutionLog(
                        ExecutionLogEntry(
                                action = "onListen",
                                details = "EventStreamHandler onListen called",
                                success = true,
                                errorMessage =
                                        "eventSinkStatus: ${if (events != null) "ACTIVE" else "NULL"}, queueSize: ${eventQueue.size}"
                        )
                )

                // 큐에 쌓인 이벤트 모두 전달
                for (event in eventQueue) {
                        try {
                                events?.success(event)
                                DataManager.addExecutionLog(
                                        ExecutionLogEntry(
                                                action = "queueEventSent",
                                                details =
                                                        "Sent queued event: ${event.take(100)}...",
                                                success = true,
                                                errorMessage =
                                                        "eventSinkStatus: ACTIVE, queueSize: ${eventQueue.size}"
                                        )
                                )
                        } catch (e: Exception) {
                                DataManager.addExecutionLog(
                                        ExecutionLogEntry(
                                                action = "queueEventError",
                                                details = "Failed to send queued event",
                                                success = false,
                                                errorMessage = e.message
                                        )
                                )
                        }
                }
                eventQueue.clear()

                DataManager.addExecutionLog(
                        ExecutionLogEntry(
                                action = "queueCleared",
                                details = "Event queue cleared after sending events",
                                success = true,
                                errorMessage = "eventSinkStatus: ACTIVE, queueSize: 0"
                        )
                )
        }

        override fun onCancel(arguments: Any?) {
                DataManager.addExecutionLog(
                        ExecutionLogEntry(
                                action = "onCancel",
                                details = "EventStreamHandler onCancel called",
                                success = true,
                                errorMessage =
                                        "eventSinkStatus: CANCELLED, queueSize: ${eventQueue.size}"
                        )
                )
                eventSink = null
        }

        fun sendEvent(event: String) {
                if (eventSink != null) {
                        try {
                                eventSink?.success(event)
                                DataManager.addExecutionLog(
                                        ExecutionLogEntry(
                                                action = "sendEvent",
                                                details =
                                                        "Event sent directly: ${event.take(100)}...",
                                                success = true,
                                                errorMessage =
                                                        "eventSinkStatus: ACTIVE, queueSize: ${eventQueue.size}"
                                        )
                                )
                        } catch (e: Exception) {
                                DataManager.addExecutionLog(
                                        ExecutionLogEntry(
                                                action = "sendEventError",
                                                details = "Failed to send event directly",
                                                success = false,
                                                errorMessage = e.message
                                        )
                                )
                        }
                } else {
                        eventQueue.add(event)
                        DataManager.addExecutionLog(
                                ExecutionLogEntry(
                                        action = "eventQueued",
                                        details = "Event added to queue: ${event.take(100)}...",
                                        success = true,
                                        errorMessage =
                                                "eventSinkStatus: NULL, queueSize: ${eventQueue.size}"
                                )
                        )
                }
        }
}
