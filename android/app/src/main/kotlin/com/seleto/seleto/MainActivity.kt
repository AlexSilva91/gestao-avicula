package com.seleto.seleto

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "seleto/critical_alerts"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "schedule" -> {
                    val id = call.argument<Int>("id")
                    val title = call.argument<String>("title")
                    val body = call.argument<String>("body")
                    val triggerAtMillis = call.argument<Number>("triggerAtMillis")?.toLong()
                    val durationMillis = call.argument<Number>("durationMillis")?.toLong()
                    if (id == null || title == null || body == null || triggerAtMillis == null) {
                        result.error("invalid_arguments", "Dados do alarme incompletos.", null)
                        return@setMethodCallHandler
                    }
                    runCatching {
                        CriticalAlarmScheduler.schedule(
                            this,
                            CriticalAlarm(
                                id,
                                title,
                                body,
                                triggerAtMillis,
                                durationMillis ?: CriticalAlarmScheduler.DEFAULT_ALARM_DURATION_MS
                            )
                        )
                    }.onSuccess {
                        result.success(null)
                    }.onFailure {
                        result.error("critical_alarm_failed", it.message, null)
                    }
                }
                "cancel" -> {
                    val id = call.argument<Int>("id")
                    if (id == null) {
                        result.error("invalid_arguments", "Id do alarme ausente.", null)
                        return@setMethodCallHandler
                    }
                    runCatching {
                        CriticalAlarmScheduler.cancel(this, id)
                    }.onSuccess {
                        result.success(null)
                    }.onFailure {
                        result.error("critical_alarm_cancel_failed", it.message, null)
                    }
                }
                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }
                "requestIgnoreBatteryOptimizations" -> {
                    runCatching {
                        requestIgnoreBatteryOptimizations()
                    }.onSuccess {
                        result.success(isIgnoringBatteryOptimizations())
                    }.onFailure {
                        result.error("battery_permission_failed", it.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(packageName)
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (isIgnoringBatteryOptimizations()) return
        val packageUri = Uri.parse("package:$packageName")
        val requestIntent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            .setData(packageUri)
        runCatching {
            startActivity(requestIntent)
        }.getOrElse {
            startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
        }
    }
}
