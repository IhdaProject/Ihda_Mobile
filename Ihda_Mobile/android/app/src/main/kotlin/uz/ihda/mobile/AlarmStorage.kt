package uz.ihda.mobile

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

data class ScheduledAlarm(
    val id: Int,
    val title: String,
    val body: String,
    val scheduledTimeMs: Long,
    val soundKey: String,
    val customAudioPath: String?,
    val targetRoute: String,
    val payload: String
) {
    fun toJson(): JSONObject {
        return JSONObject().apply {
            put("id", id)
            put("title", title)
            put("body", body)
            put("scheduledTimeMs", scheduledTimeMs)
            put("soundKey", soundKey)
            put("customAudioPath", customAudioPath ?: "")
            put("targetRoute", targetRoute)
            put("payload", payload)
        }
    }

    companion object {
        fun fromJson(json: JSONObject): ScheduledAlarm {
            return ScheduledAlarm(
                id = json.getInt("id"),
                title = json.optString("title", ""),
                body = json.optString("body", ""),
                scheduledTimeMs = json.getLong("scheduledTimeMs"),
                soundKey = json.optString("soundKey", "default"),
                customAudioPath = json.optString("customAudioPath", "").ifEmpty { null },
                targetRoute = json.optString("targetRoute", "/"),
                payload = json.optString("payload", "")
            )
        }
    }
}

class AlarmStorage(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("uz.ihda.mobile.alarms_v2", Context.MODE_PRIVATE)

    fun saveAlarm(alarm: ScheduledAlarm) {
        val alarms = getAlarms().toMutableList()
        alarms.removeAll { it.id == alarm.id }
        alarms.add(alarm)
        saveAlarmsList(alarms)
    }

    fun removeAlarm(id: Int) {
        val alarms = getAlarms().toMutableList()
        alarms.removeAll { it.id == id }
        saveAlarmsList(alarms)
    }

    fun clearAll() {
        prefs.edit().remove("scheduled_alarms").apply()
    }

    fun getAlarms(): List<ScheduledAlarm> {
        val jsonStr = prefs.getString("scheduled_alarms", null) ?: return emptyList()
        val list = mutableListOf<ScheduledAlarm>()
        try {
            val jsonArray = JSONArray(jsonStr)
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                list.add(ScheduledAlarm.fromJson(obj))
            }
        } catch (_: Exception) {}
        return list
    }

    private fun saveAlarmsList(alarms: List<ScheduledAlarm>) {
        val jsonArray = JSONArray()
        for (alarm in alarms) {
            jsonArray.put(alarm.toJson())
        }
        prefs.edit().putString("scheduled_alarms", jsonArray.toString()).apply()
    }
}
