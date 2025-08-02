package com.example.diary_ai

import android.app.Application
import com.example.diary_ai.MainActivity
import com.loplat.placeengine.Plengi
import com.loplat.placeengine.PlengiListener
import com.loplat.placeengine.PlengiResponse
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainApplication: Application() {
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onCreate() {
        super.onCreate()

        // DataManager 초기화
        DataManager.initialize(this)

        // Plengi 초기화는 별도의 코루틴에서 비동기적으로 수행
        CoroutineScope(Dispatchers.IO).launch {
            Plengi.getInstance(this@MainApplication).listener =
                object : PlengiListener {
                    override fun listen(response: PlengiResponse?) {
                        println(
                            "EventStreamHandler: PlengiListener listen is called:" +
                                    response.toString()
                        )

                        // 위치 히스토리에 저장 (SharedPreferences에만 저장)
                        try {
                            val locationEntry = DataManager.createLocationHistoryEntry(response)
                            DataManager.addLocationHistory(locationEntry)
                            println(
                                "Location history saved to SharedPreferences: ${locationEntry.placeName}"
                            )
                            // 실행 내역 기록
                            DataManager.addExecutionLog(
                                ExecutionLogEntry(
                                    action = "PlengiListener listen",
                                    details = "PlengiListener listen called!!"
                                )
                            )
                        } catch (e: Exception) {
                            println("Failed to save location history: ${e.message}")
                            DataManager.addExecutionLog(
                                ExecutionLogEntry(
                                    action = "locationHistorySaveError",
                                    details = "Failed to save location history",
                                    success = false,
                                    errorMessage = e.message
                                )
                            )
                        }
                    }
                }

            Plengi.getInstance(this@MainApplication).start()
        }
    }
}