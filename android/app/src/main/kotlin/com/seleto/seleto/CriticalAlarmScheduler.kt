package com.seleto.seleto

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONObject

data class CriticalAlarm(
    val id: Int,
    val title: String,
    val body: String,
    val triggerAtMillis: Long,
    val durationMillis: Long = CriticalAlarmScheduler.DEFAULT_ALARM_DURATION_MS
)

object CriticalAlarmScheduler {
    fun schedule(context: Context, alarm: CriticalAlarm, persist: Boolean = true) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            throw SecurityException("Permissao de alarmes exatos nao concedida.")
        }
        val showPendingIntent = PendingIntent.getActivity(
            context,
            alarm.id,
            launchIntent(context),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.setAlarmClock(
            AlarmManager.AlarmClockInfo(alarm.triggerAtMillis, showPendingIntent),
            pendingIntent(context, alarm)
        )
        if (persist) save(context, alarm)
    }

    fun cancel(context: Context, id: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent(context, CriticalAlarm(id, "", "", 0L)))
        prefs(context).edit().remove(id.toString()).apply()
    }

    fun rescheduleSaved(context: Context) {
        val now = System.currentTimeMillis()
        val editor = prefs(context).edit()
        prefs(context).all.forEach { (key, value) ->
            val alarm = (value as? String)?.let { parse(it) } ?: return@forEach
            if (alarm.triggerAtMillis <= now) {
                editor.remove(key)
                return@forEach
            }
            runCatching { schedule(context, alarm, persist = false) }
        }
        editor.apply()
    }

    private fun save(context: Context, alarm: CriticalAlarm) {
        val json = JSONObject()
            .put("id", alarm.id)
            .put("title", alarm.title)
            .put("body", alarm.body)
            .put("triggerAtMillis", alarm.triggerAtMillis)
            .put("durationMillis", alarm.durationMillis)
            .toString()
        prefs(context).edit().putString(alarm.id.toString(), json).apply()
    }

    private fun parse(value: String): CriticalAlarm? = runCatching {
        val json = JSONObject(value)
        CriticalAlarm(
            id = json.getInt("id"),
            title = json.getString("title"),
            body = json.getString("body"),
            triggerAtMillis = json.getLong("triggerAtMillis"),
            durationMillis = json.optLong("durationMillis", DEFAULT_ALARM_DURATION_MS)
        )
    }.getOrNull()

    private fun pendingIntent(context: Context, alarm: CriticalAlarm): PendingIntent {
        val intent = Intent(context, CriticalAlarmReceiver::class.java)
            .setAction("com.seleto.seleto.CRITICAL_ALARM")
            .putExtra("id", alarm.id)
            .putExtra("title", alarm.title)
            .putExtra("body", alarm.body)
            .putExtra("durationMillis", alarm.durationMillis)
        return PendingIntent.getBroadcast(
            context,
            alarm.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun launchIntent(context: Context): Intent =
        context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            ?: Intent(context, MainActivity::class.java)

    private fun prefs(context: Context) =
        context.getSharedPreferences("seleto_critical_alarms", Context.MODE_PRIVATE)

    const val DEFAULT_ALARM_DURATION_MS = 30_000L
}
