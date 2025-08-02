package com.example.diary_ai

import android.content.pm.PackageManager
import android.os.Build
import android.widget.Toast
import androidx.core.content.edit
import com.google.gson.Gson
import com.loplat.placeengine.OnPlengiListener
import com.loplat.placeengine.Plengi
import com.loplat.placeengine.PlengiListener
import com.loplat.placeengine.PlengiResponse
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "plengi.ai/fromFlutter"
    private val EVENT_CHANNEL = "plengi.ai/toFlutter"
    private val LOCATION_PERMISSION_REQUEST_CODE = 10001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MethodChannel 설정
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "searchPlace" -> {
                            searchPlace(result)
                        }
                        "plengiStartStop" -> {
                            Plengi.getInstance(this).stop()
                            Plengi.getInstance(this).start()
                            result.success(null)
                        }
                        "saveCallbackHandle" -> {
                            val handle = call.argument<Number>("handle")?.toLong() ?: 0L
                            // SharedPreferences에 저장
                            getSharedPreferences("background_location_saver", MODE_PRIVATE).edit() {
                                putLong("callback_handle", handle)
                            }
                            println("saveCallbackHandle, handle: " + handle)
                            result.success(null)
                        }
                        "getLocationHistory" -> {
                            val history = DataManager.getLocationHistory()
                            result.success(Gson().toJson(history))
                        }
                        "getExecutionLogs" -> {
                            val logs = DataManager.getExecutionLogs()
                            result.success(Gson().toJson(logs))
                        }
                        "getStats" -> {
                            val stats = DataManager.getStats()
                            result.success(stats)
                        }
                        "clearAllData" -> {
                            DataManager.clearAllData()
                            result.success("All data cleared")
                        }
                        else -> {
                            result.notImplemented()
                        }
                    }
                }

        // EventChannel 설정 (앱 foreground 시에만 사용)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
                .setStreamHandler(EventStreamHandler)
    }

    private fun checkPermissionForTask(permissions: ArrayList<String>, requestCode: Int): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val deniedPermissions = arrayListOf<String>()
            for (permission in permissions) {
                if (checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
                    deniedPermissions.add(permission)
                }
            }

            if (!deniedPermissions.isEmpty()) {
                for (deniedPermission in deniedPermissions) {
                    if (shouldShowRequestPermissionRationale(deniedPermission)) {
                        // 권한 설명이 필요한 경우
                    }
                }
                requestPermissions(deniedPermissions.toTypedArray(), requestCode)
                return false
            }
        }
        return true
    }

    private fun searchPlace(result: MethodChannel.Result) {
        val checkPermissions: ArrayList<String> =
                arrayListOf(
                        android.Manifest.permission.ACCESS_FINE_LOCATION,
                        android.Manifest.permission.ACCESS_COARSE_LOCATION
                )
        if (checkPermissionForTask(checkPermissions, LOCATION_PERMISSION_REQUEST_CODE)) {
            Plengi.getInstance(this)
                    .TEST_refreshPlace_foreground(
                            object : OnPlengiListener {
                                override fun onSuccess(response: PlengiResponse?) {
                                    // 위치 히스토리에 저장 (SharedPreferences에만 저장)
                                    try {
                                        val locationEntry =
                                                DataManager.createLocationHistoryEntry(response)
                                        DataManager.addLocationHistory(locationEntry)
                                        println(
                                                "Location history saved to SharedPreferences: ${locationEntry.placeName}"
                                        )

                                        // EventChannel을 통해 위치 히스토리 업데이트 알림 전송
                                        EventStreamHandler.sendEvent("location_history_updated")
                                        println(
                                                "Sent location history update notification to Flutter"
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
                                    result.success(Gson().toJson(response))
                                }

                                override fun onFail(response: PlengiResponse?) {
                                    result.error(
                                            "PlengiResponse",
                                            "PlengiResponse",
                                            Gson().toJson(response)
                                    )
                                    Toast.makeText(
                                                    this@MainActivity,
                                                    "현재 위치를 확인 할 수 없습니다.",
                                                    Toast.LENGTH_SHORT
                                            )
                                            .show()
                                }
                            }
                    )
        }
    }
}
