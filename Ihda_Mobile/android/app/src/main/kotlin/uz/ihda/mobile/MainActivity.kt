package uz.ihda.mobile

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "uz.ihda.mobile/notifications"
    private var methodChannel: MethodChannel? = null
    private var initialRoute: String? = null
    private var initialPayload: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        try {
            MapKitFactory.setApiKey("7f9b9650-fcf6-4194-8005-1b2c65deba21")
        } catch (_: Throwable) {}
        try {
            MapKitFactory.initialize(this)
        } catch (_: Throwable) {}
        super.onCreate(savedInstanceState)
        handleNotificationIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleNotificationIntent(intent)
        if (intent.getBooleanExtra("fromNotification", false)) {
            val route = intent.getStringExtra("targetRoute") ?: "/"
            val payload = intent.getStringExtra("payload") ?: ""
            val data = mapOf("targetRoute" to route, "payload" to payload)
            methodChannel?.invokeMethod("onNotificationTapped", data)
        }
    }

    private fun handleNotificationIntent(intent: Intent?) {
        if (intent != null && intent.getBooleanExtra("fromNotification", false)) {
            initialRoute = intent.getStringExtra("targetRoute") ?: "/"
            initialPayload = intent.getStringExtra("payload") ?: ""
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel = channel

        channel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            try {
            when (call.method) {
                "scheduleAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val title = call.argument<String>("title") ?: ""
                    val body = call.argument<String>("body") ?: ""
                    val scheduledTimeMs = (call.argument<Number>("scheduledTimeMs"))?.toLong() ?: 0L
                    val soundKey = call.argument<String>("soundKey") ?: "default"
                    val customAudioPath = call.argument<String>("customAudioPath")
                    val targetRoute = call.argument<String>("targetRoute") ?: "/"
                    val payload = call.argument<String>("payload") ?: ""

                    val alarm = ScheduledAlarm(
                        id = id,
                        title = title,
                        body = body,
                        scheduledTimeMs = scheduledTimeMs,
                        soundKey = soundKey,
                        customAudioPath = customAudioPath,
                        targetRoute = targetRoute,
                        payload = payload
                    )

                    val storage = AlarmStorage(this)
                    storage.saveAlarm(alarm)
                    scheduleAlarmNative(alarm)
                    result.success(true)
                }

                "cancelAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val storage = AlarmStorage(this)
                    storage.removeAlarm(id)
                    cancelAlarmNative(id)
                    result.success(true)
                }

                "cancelAllAlarms" -> {
                    val storage = AlarmStorage(this)
                    val alarms = storage.getAlarms()
                    for (alarm in alarms) {
                        cancelAlarmNative(alarm.id)
                    }
                    storage.clearAll()
                    result.success(true)
                }

                "showImmediateNotification" -> {
                    val id = call.argument<Int>("id") ?: (System.currentTimeMillis() % 100000).toInt()
                    val title = call.argument<String>("title") ?: "Sinov Bildirishnomasi"
                    val body = call.argument<String>("body") ?: "Sinov xabari matni"
                    val soundKey = call.argument<String>("soundKey") ?: "default"
                    val customAudioPath = call.argument<String>("customAudioPath")
                    val targetRoute = call.argument<String>("targetRoute") ?: "/"
                    val payload = call.argument<String>("payload") ?: ""

                    val intent = Intent(this, PrayerAlarmReceiver::class.java).apply {
                        putExtra("id", id)
                        putExtra("title", title)
                        putExtra("body", body)
                        putExtra("soundKey", soundKey)
                        putExtra("customAudioPath", customAudioPath)
                        putExtra("targetRoute", targetRoute)
                        putExtra("payload", payload)
                    }
                    if (!androidx.core.app.NotificationManagerCompat.from(this).areNotificationsEnabled()) {
                        throw SecurityException("Bildirishnomalarga ruxsat berilmagan")
                    }
                    PrayerAlarmReceiver().onReceive(this, intent)
                    result.success(true)
                }

                "getInitialNotificationPayload" -> {
                    val route = initialRoute
                    if (route != null) {
                        val data = mapOf(
                            "targetRoute" to route,
                            "payload" to (initialPayload ?: "")
                        )
                        initialRoute = null
                        initialPayload = null
                        result.success(data)
                    } else {
                        result.success(null)
                    }
                }

                else -> result.notImplemented()
            }
            } catch (error: Exception) {
                result.error("NOTIFICATION_ERROR", error.message, null)
            }
        }
    }

    private fun scheduleAlarmNative(alarm: ScheduledAlarm) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, PrayerAlarmReceiver::class.java).apply {
            putExtra("id", alarm.id)
            putExtra("title", alarm.title)
            putExtra("body", alarm.body)
            putExtra("soundKey", alarm.soundKey)
            putExtra("customAudioPath", alarm.customAudioPath)
            putExtra("targetRoute", alarm.targetRoute)
            putExtra("payload", alarm.payload)
        }

        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getBroadcast(this, alarm.id, intent, pendingFlags)

        val showIntent = Intent(this, MainActivity::class.java)
        val showPendingIntent = PendingIntent.getActivity(this, alarm.id, showIntent, pendingFlags)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarm.scheduledTimeMs, pendingIntent)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val alarmClockInfo = AlarmManager.AlarmClockInfo(alarm.scheduledTimeMs, showPendingIntent)
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, alarm.scheduledTimeMs, pendingIntent)
        }
    }

    private fun cancelAlarmNative(id: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, PrayerAlarmReceiver::class.java)
        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getBroadcast(this, id, intent, pendingFlags)
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }
}
