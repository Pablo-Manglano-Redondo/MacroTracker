package com.epsait.macrotracker

import android.util.Log
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.TotalCaloriesBurnedRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import cachet.plugins.health.HealthConstants
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val HEALTH_CONNECT_CHANNEL = "macrotracker/health_connect"
        private const val TAG = "MacroTrackerHealth"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HEALTH_CONNECT_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "readWorkouts" -> {
                    val startTimeMillis = call.argument<Long>("startTime")
                    val endTimeMillis = call.argument<Long>("endTime")

                    if (startTimeMillis == null || endTimeMillis == null) {
                        result.error(
                            "invalid_args",
                            "startTime and endTime are required",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val client = HealthConnectClient.getOrCreate(applicationContext)
                            val workouts = readWorkouts(
                                client,
                                Instant.ofEpochMilli(startTimeMillis),
                                Instant.ofEpochMilli(endTimeMillis),
                            )
                            runOnUiThread { result.success(workouts) }
                        } catch (error: Exception) {
                            runOnUiThread {
                                result.error(
                                    "read_workouts_failed",
                                    error.message,
                                    error.stackTraceToString(),
                                )
                            }
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private suspend fun readWorkouts(
        client: HealthConnectClient,
        startTime: Instant,
        endTime: Instant,
    ): List<Map<String, Any?>> {
        val sessions = mutableListOf<ExerciseSessionRecord>()
        var pageToken: String? = null

        do {
            val request = if (pageToken.isNullOrEmpty()) {
                ReadRecordsRequest(
                    recordType = ExerciseSessionRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startTime, endTime),
                )
            } else {
                ReadRecordsRequest(
                    recordType = ExerciseSessionRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startTime, endTime),
                    pageToken = pageToken,
                )
            }

            val response = client.readRecords(request)
            sessions.addAll(response.records)
            pageToken = response.pageToken
        } while (!pageToken.isNullOrEmpty())

        Log.i(TAG, "Native workout reader found ${sessions.size} exercise sessions")

        return sessions.mapNotNull { session ->
            try {
                val workoutTypeName = HealthConstants.workoutTypeMap.entries
                    .firstOrNull { entry -> entry.value == session.exerciseType }
                    ?.key
                    ?: "OTHER"

                mapOf(
                    "uuid" to session.metadata.id,
                    "workoutActivityType" to workoutTypeName,
                    "totalEnergyBurned" to readWorkoutCalories(client, session),
                    "date_from" to session.startTime.toEpochMilli(),
                    "date_to" to session.endTime.toEpochMilli(),
                    "source_id" to "",
                    "source_name" to session.metadata.dataOrigin.packageName,
                )
            } catch (error: Exception) {
                Log.e(TAG, "Skipping malformed exercise session", error)
                null
            }
        }
    }

    private suspend fun readWorkoutCalories(
        client: HealthConnectClient,
        session: ExerciseSessionRecord,
    ): Double? {
        return try {
            val response = client.readRecords(
                ReadRecordsRequest(
                    recordType = TotalCaloriesBurnedRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        session.startTime,
                        session.endTime,
                    ),
                ),
            )
            val totalCalories = response.records.sumOf { record ->
                record.energy.inKilocalories
            }
            if (totalCalories > 0.0) totalCalories else null
        } catch (error: Exception) {
            Log.w(TAG, "Workout calories unavailable for session ${session.metadata.id}", error)
            null
        }
    }
}
