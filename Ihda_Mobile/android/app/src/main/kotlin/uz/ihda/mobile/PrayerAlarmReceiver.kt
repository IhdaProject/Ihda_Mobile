package uz.ihda.mobile

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat

class PrayerAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("id", 0)
        val title = intent.getStringExtra("title") ?: "Namoz Vaqti"
        val body = intent.getStringExtra("body") ?: "Hozir namoz vaqti kirdi."
        val soundKey = intent.getStringExtra("soundKey") ?: "default"
        val customAudioPath = intent.getStringExtra("customAudioPath")
        val targetRoute = intent.getStringExtra("targetRoute") ?: "/"
        val payload = intent.getStringExtra("payload") ?: ""

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (!androidx.core.app.NotificationManagerCompat.from(context).areNotificationsEnabled()) {
            throw SecurityException("Bildirishnomalarga ruxsat berilmagan")
        }
        // Create distinct channel ID per soundKey to allow immediate sound changes on Android 8+
        val channelId = "prayer_channel_$soundKey" + if (soundKey == "custom") "_${customAudioPath.orEmpty().hashCode()}" else ""
        val channelName = when (soundKey) {
            "azan" -> "Namoz Vaqti - Azon Ovozi"
            "short_chime" -> "Namoz Vaqti - Qisqa Tovush"
            "silent" -> "Namoz Vaqti - Ovsiz"
            "custom" -> "Namoz Vaqti - Shaxsiy Ovoz"
            else -> "Namoz Vaqti - Standart"
        }

        val soundUri: Uri? = when (soundKey) {
            "azan" -> {
                val resId = context.resources.getIdentifier("chalo_chalo", "raw", context.packageName)
                if (resId != 0) {
                    Uri.parse("android.resource://${context.packageName}/$resId")
                } else {
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                }
            }
            "short_chime" -> {
                val resId = context.resources.getIdentifier("short_chime", "raw", context.packageName)
                if (resId != 0) {
                    Uri.parse("android.resource://${context.packageName}/$resId")
                } else {
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                }
            }
            "custom" -> {
                if (!customAudioPath.isNullOrEmpty()) {
                    if (customAudioPath.startsWith("content://")) Uri.parse(customAudioPath)
                    else {
                        val source = java.io.File(Uri.parse(customAudioPath).path ?: customAudioPath)
                        require(source.isFile) { "Audio fayli topilmadi" }
                        val directory = java.io.File(context.filesDir, "notification_audio").apply { mkdirs() }
                        val destination = java.io.File(directory, "${source.absolutePath.hashCode()}_${source.name}")
                        if (!destination.exists()) source.copyTo(destination)
                        val uri = androidx.core.content.FileProvider.getUriForFile(context, "${context.packageName}.notification_audio", destination)
                        context.grantUriPermission("com.android.systemui", uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        uri
                    }
                } else {
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                }
            }
            "silent" -> null
            else -> RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_ALARM)
                .build()

            val importance = if (soundKey == "silent") {
                NotificationManager.IMPORTANCE_DEFAULT
            } else {
                NotificationManager.IMPORTANCE_HIGH
            }

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = "Namoz vaqtlari eslatmalari bildirishnomalari"
                enableVibration(true)
                if (soundUri != null) {
                    setSound(soundUri, audioAttributes)
                } else {
                    setSound(null, null)
                }
            }
            notificationManager.createNotificationChannel(channel)
        }

        // Tap intent to launch app and navigate to target route
        val tapIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("targetRoute", targetRoute)
            putExtra("payload", payload)
            putExtra("fromNotification", true)
        }

        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getActivity(context, id, tapIntent, pendingFlags)

        val smallIconId = context.resources.getIdentifier("ic_stat_prayer", "drawable", context.packageName)
            .let { if (it != 0) it else context.resources.getIdentifier("launcher_icon", "mipmap", context.packageName) }

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(if (smallIconId != 0) smallIconId else android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(pendingIntent)

        if (soundUri != null) {
            builder.setSound(soundUri)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            notificationManager.getNotificationChannel(channelId)?.importance == NotificationManager.IMPORTANCE_NONE) {
            throw SecurityException("Bildirishnoma kanali o‘chirilgan")
        }
        notificationManager.notify(id, builder.build())

        // Clean up executed alarm from storage
        AlarmStorage(context).removeAlarm(id)
    }
}
