package com.example.diary_ai

import com.google.gson.annotations.SerializedName
import java.util.Date

data class LocationHistoryEntry(
        @SerializedName("timestamp") val timestamp: Long = System.currentTimeMillis(),
        @SerializedName("date") val date: String = Date().toString(),
        @SerializedName("placeName") val placeName: String? = null,
        @SerializedName("address") val address: String? = null,
        @SerializedName("latitude") val latitude: Double? = null,
        @SerializedName("longitude") val longitude: Double? = null,
        @SerializedName("rawResponse") val rawResponse: String? = null
)
