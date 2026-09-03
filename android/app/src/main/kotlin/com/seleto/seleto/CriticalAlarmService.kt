package com.seleto.seleto

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import kotlin.math.max

class CriticalAlarmService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var player: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val id = intent?.getIntExtra("id", System.currentTimeMillis().toInt())
            ?: System.currentTimeMillis().toInt()
        val title = intent?.getStringExtra("title") ?: "GRANJA SELETO"
        val body = intent?.getStringExtra("body") ?: "Alerta operacional"
        val durationMillis = intent?.getLongExtra(
            "durationMillis",
            CriticalAlarmScheduler.DEFAULT_ALARM_DURATION_MS
        )?.coerceIn(1_000L, 120_000L)
            ?: CriticalAlarmScheduler.DEFAULT_ALARM_DURATION_MS

        ensureAlarmChannel()
        startForeground(id, buildNotification(id, title, body))
        startSignal(durationMillis)
        handler.removeCallbacksAndMessages(null)
        handler.postDelayed({
            stopSelfResult(startId)
        }, durationMillis)
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        stopSignal()
        super.onDestroy()
    }

    private fun startSignal(durationMillis: Long) {
        stopSignal()
        acquireWakeLock(durationMillis)
        raiseAlarmVolume()
        player = startAlarmSound()
        vibrator = startVibration()
    }

    private fun stopSignal() {
        player?.runCatching {
            stop()
            release()
        }
        player = null
        vibrator?.cancel()
        vibrator = null
        if (wakeLock?.isHeld == true) wakeLock?.release()
        wakeLock = null
    }

    private fun acquireWakeLock(durationMillis: Long) {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "SELETO:CriticalAlarmService"
        ).apply {
            setReferenceCounted(false)
            acquire(durationMillis + 5_000L)
        }
    }

    private fun ensureAlarmChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Alertas sonoros GRANJA SELETO",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Alertas operacionais com som, vibracao e prioridade de alarme"
            enableVibration(true)
            runCatching { setBypassDnd(true) }
            setSound(null, alarmAudioAttributes())
        }
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(id: Int, title: String, body: String): Notification {
        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            ?: Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            id,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
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
    }

    private fun raiseAlarmVolume() {
        val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maxVolume = audio.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        val current = audio.getStreamVolume(AudioManager.STREAM_ALARM)
        val target = max(1, max(maxVolume / 2, current))
        if (current < target) {
            audio.setStreamVolume(AudioManager.STREAM_ALARM, target, 0)
        }
    }

    private fun startAlarmSound(): MediaPlayer? {
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            ?: return null
        return runCatching {
            MediaPlayer().apply {
                setDataSource(this@CriticalAlarmService, uri)
                setAudioAttributes(alarmAudioAttributes())
                isLooping = true
                prepare()
                start()
            }
        }.getOrNull()
    }

    private fun startVibration(): Vibrator? {
        val alarmVibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        val pattern = longArrayOf(0L, 900L, 350L, 900L, 350L, 900L)
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                alarmVibrator.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                alarmVibrator.vibrate(pattern, 0)
            }
        }
        return alarmVibrator
    }

    private fun alarmAudioAttributes(): AudioAttributes =
        AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

    private companion object {
        const val CHANNEL_ID = "seleto_alarm"
    }
}
