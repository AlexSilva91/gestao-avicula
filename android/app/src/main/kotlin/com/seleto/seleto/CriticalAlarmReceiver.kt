package com.seleto.seleto

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import kotlin.math.max

class CriticalAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val appContext = context.applicationContext
        val id = intent.getIntExtra("id", System.currentTimeMillis().toInt())
        val title = intent.getStringExtra("title") ?: "GRANJA SELETO"
        val body = intent.getStringExtra("body") ?: "Alerta operacional"
        val durationMillis = intent.getLongExtra(
            "durationMillis",
            CriticalAlarmScheduler.DEFAULT_ALARM_DURATION_MS
        ).coerceIn(1_000L, 120_000L)
        if (startAlarmService(appContext, id, title, body, durationMillis)) {
            return
        }
        val wakeLock = acquireWakeLock(appContext, durationMillis)

        ensureAlarmChannel(appContext)
        raiseAlarmVolume(appContext)
        showAlarmNotification(appContext, id, title, body)
        val player = startAlarmSound(appContext)
        val vibrator = startVibration(appContext)

        Handler(Looper.getMainLooper()).postDelayed({
            player?.runCatching {
                stop()
                release()
            }
            vibrator?.cancel()
            if (wakeLock?.isHeld == true) wakeLock.release()
        }, durationMillis)
    }

    private fun startAlarmService(
        context: Context,
        id: Int,
        title: String,
        body: String,
        durationMillis: Long
    ): Boolean = runCatching {
        val serviceIntent = Intent(context, CriticalAlarmService::class.java)
            .putExtra("id", id)
            .putExtra("title", title)
            .putExtra("body", body)
            .putExtra("durationMillis", durationMillis)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }.isSuccess

    private fun acquireWakeLock(context: Context, durationMillis: Long): PowerManager.WakeLock? {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "SELETO:CriticalAlarm"
        ).apply {
            setReferenceCounted(false)
            acquire(durationMillis + 5_000L)
        }
    }

    private fun ensureAlarmChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Alertas sonoros GRANJA SELETO",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Alertas operacionais com som, vibracao e prioridade de alarme"
            enableVibration(true)
            runCatching { setBypassDnd(true) }
            setSound(null, audioAttributes)
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    private fun raiseAlarmVolume(context: Context) {
        val audio = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maxVolume = audio.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        val current = audio.getStreamVolume(AudioManager.STREAM_ALARM)
        val target = max(1, max(maxVolume / 2, current))
        if (current < target) {
            audio.setStreamVolume(AudioManager.STREAM_ALARM, target, 0)
        }
    }

    private fun showAlarmNotification(
        context: Context,
        id: Int,
        title: String,
        body: String
    ) {
        val openAppIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            ?: Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context,
            id,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        val notification = builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setOngoing(false)
            .setShowWhen(true)
            .setPriority(Notification.PRIORITY_MAX)
            .setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setFullScreenIntent(pendingIntent, true)
            .build()
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        runCatching { manager.notify(id, notification) }
    }

    private fun startAlarmSound(context: Context): MediaPlayer? {
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            ?: return null
        return runCatching {
            MediaPlayer().apply {
                setDataSource(context, uri)
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                isLooping = true
                prepare()
                start()
            }
        }.getOrNull()
    }

    private fun startVibration(context: Context): Vibrator? {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        val pattern = longArrayOf(0L, 900L, 350L, 900L, 350L, 900L)
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(pattern, 0)
            }
        }
        return vibrator
    }

    private companion object {
        const val CHANNEL_ID = "seleto_alarm"
    }
}
