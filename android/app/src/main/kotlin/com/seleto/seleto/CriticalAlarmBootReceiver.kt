package com.seleto.seleto

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class CriticalAlarmBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            "android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED" ->
                CriticalAlarmScheduler.rescheduleSaved(context.applicationContext)
        }
    }
}
