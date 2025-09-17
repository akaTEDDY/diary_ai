package com.example.diary_ai

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.loplat.placeengine.PlengiResponse

object DataManager {
    private const val LOCATION_HISTORY_KEY = "location_history"
    private const val EXECUTION_LOG_KEY = "execution_log"
    private const val MAX_HISTORY_SIZE = 100
    private const val MAX_LOG_SIZE = 500

    private lateinit var sharedPreferences: SharedPreferences
    private val gson = Gson()

    fun initialize(context: Context) {
        sharedPreferences = context.getSharedPreferences("diary_ai_data", Context.MODE_PRIVATE)
    }

    // 최근 장소 하나만 조회하는 함수
    fun getLatestLocationHistory(): LocationHistoryEntry? {
        val history = getLocationHistory()
        return history.lastOrNull()
    }

    // 위치 히스토리 관리
    fun addLocationHistory(entry: LocationHistoryEntry) {
        val history = getLocationHistory().toMutableList()
        history.add(entry)

        // 최대 크기 제한
        if (history.size > MAX_HISTORY_SIZE) {
            history.removeAt(0)
        }

        saveLocationHistory(history)
        println("LocationHistory added: ${entry.placeName} at ${entry.date}")
    }

    fun getLocationHistory(): List<LocationHistoryEntry> {
        val json = sharedPreferences.getString(LOCATION_HISTORY_KEY, "[]")
        val type = object : TypeToken<List<LocationHistoryEntry>>() {}.type
        return try {
            gson.fromJson(json, type) ?: emptyList()
        } catch (e: Exception) {
            println("Error parsing location history: ${e.message}")
            emptyList()
        }
    }

    private fun saveLocationHistory(history: List<LocationHistoryEntry>) {
        val json = gson.toJson(history)
        sharedPreferences.edit().putString(LOCATION_HISTORY_KEY, json).apply()
    }

    // 실행 내역 관리
    fun addExecutionLog(entry: ExecutionLogEntry) {
        val logs = getExecutionLogs().toMutableList()
        logs.add(entry)

        // 최대 크기 제한
        if (logs.size > MAX_LOG_SIZE) {
            logs.removeAt(0)
        }

        saveExecutionLogs(logs)
        println("ExecutionLog added: ${entry.action} - ${entry.details}")
    }

    fun getExecutionLogs(): List<ExecutionLogEntry> {
        val json = sharedPreferences.getString(EXECUTION_LOG_KEY, "[]")
        val type = object : TypeToken<List<ExecutionLogEntry>>() {}.type
        return try {
            gson.fromJson(json, type) ?: emptyList()
        } catch (e: Exception) {
            println("Error parsing execution logs: ${e.message}")
            emptyList()
        }
    }

    private fun saveExecutionLogs(logs: List<ExecutionLogEntry>) {
        val json = gson.toJson(logs)
        sharedPreferences.edit().putString(EXECUTION_LOG_KEY, json).apply()
    }

    // PlengiResponse를 LocationHistoryEntry로 변환
    fun createLocationHistoryEntry(response: PlengiResponse?): LocationHistoryEntry {
        return LocationHistoryEntry(
                placeName = response?.place?.name,
                address = response?.place?.address_road ?: response?.place?.address,
                latitude = response?.place?.lat ?: response?.location?.lat,
                longitude = response?.place?.lng ?: response?.location?.lng,
                rawResponse = gson.toJson(response)
        )
    }

    // 데이터 초기화 (디버깅용)
    fun clearAllData() {
        sharedPreferences.edit().remove(LOCATION_HISTORY_KEY).remove(EXECUTION_LOG_KEY).apply()
        println("All data cleared")
    }

    // 통계 정보
    fun getStats(): String {
        val historyCount = getLocationHistory().size
        val logCount = getExecutionLogs().size
        return "Location History: $historyCount entries, Execution Logs: $logCount entries"
    }
}
