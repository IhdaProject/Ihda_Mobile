package uz.ihda.mobile

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED) {

            val storage = AlarmStorage(context)
            val alarms = storage.getAlarms()
            val now = System.currentTimeMillis()
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            for (alarm in alarms) {
                if (alarm.scheduledTimeMs > now) {
                    scheduleNativeAlarm(context, alarmManager, alarm)
                } else {
                    storage.removeAlarm(alarm.id)
                }
            }
        }
    }

    private fun scheduleNativeAlarm(context: Context, alarmManager: AlarmManager, alarm: ScheduledAlarm) {
        val intent = Intent(context, PrayerAlarmReceiver::class.java).apply {
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

        val pendingIntent = PendingIntent.getBroadcast(context, alarm.id, intent, pendingFlags)

        val showIntent = Intent(context, MainActivity::class.java)
        val showPendingIntent = PendingIntent.getActivity(context, alarm.id, showIntent, pendingFlags)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val alarmClockInfo = AlarmManager.AlarmClockInfo(alarm.scheduledTimeMs, showPendingIntent)
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, alarm.scheduledTimeMs, pendingIntent)
        }
    }
}
