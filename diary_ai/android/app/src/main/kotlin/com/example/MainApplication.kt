package com.example.diary_ai

import android.app.Application
import com.loplat.placeengine.Plengi
import com.loplat.placeengine.PlengiListener
import com.loplat.placeengine.PlengiResponse
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainApplication : Application() {
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
                                if (response == null) {
                                    return
                                }
                                val place = response.place
                                if (place != null) {
                                    val placeName = place.name
                                    val placeAddress = place.address
                                    val accuracy = place.accuracy
                                    val threshold = place.threshold

                                    if (placeName == null || placeAddress == null) {
                                        return
                                    }

                                    // 최근 장소가 동일 장소인 경우 스킵
                                    val latestLocation = DataManager.getLatestLocationHistory()
                                    if (latestLocation != null) {
                                        // 장소명과 주소가 모두 동일한 경우 중복으로 간주
                                        if (latestLocation.placeName == placeName &&
                                                        latestLocation.address == placeAddress
                                        ) {
                                            println("Skipping duplicate location: $placeName")
                                            return
                                        }
                                    }

                                    // 정확도가 임계값 이상이거나 0.3 이상인 경우 저장
                                    if (accuracy >= threshold || accuracy > 0.35) {
                                        val locationEntry =
                                                DataManager.createLocationHistoryEntry(response)
                                        DataManager.addLocationHistory(locationEntry)

                                        println(
                                                "Location history saved to SharedPreferences: ${locationEntry.placeName}"
                                        )

                                        // EventChannel을 통해 위치 히스토리 업데이트 알림 전송 (FG에서 동작하는 경우를 위함)
                                        EventStreamHandler.sendEvent("location_history_updated")
                                        println(
                                                "Sent location history update notification to Flutter"
                                        )
                                    } else {
                                        DataManager.addExecutionLog(
                                                ExecutionLogEntry(
                                                        action = "locationHistorySaveSuccess",
                                                        details = "Accuracy is less than threshold",
                                                        success = true,
                                                        errorMessage =
                                                                "placeName: $placeName, accuracy: $accuracy, threshold: $threshold"
                                                )
                                        )
                                    }
                                }
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
