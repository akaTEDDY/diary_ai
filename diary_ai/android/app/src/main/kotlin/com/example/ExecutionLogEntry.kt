package com.example.diary_ai

import com.google.gson.annotations.SerializedName
import java.util.Date

data class ExecutionLogEntry(
        @SerializedName("timestamp") val timestamp: Long = System.currentTimeMillis(),
        @SerializedName("date") val date: String = Date().toString(),
        @SerializedName("action") val action: String,
        @SerializedName("details") val details: String? = null,
        @SerializedName("eventSinkStatus") val eventSinkStatus: String? = null,
        @SerializedName("queueSize") val queueSize: Int? = null,
        @SerializedName("success") val success: Boolean = true,
        @SerializedName("errorMessage") val errorMessage: String? = null
)
