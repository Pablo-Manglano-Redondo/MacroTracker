package com.epsait.macrotracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class MacroTrackerCircularProgressWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.macrotracker_circular_progress_widget,
            ).apply {
                val launchIntent =
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_container, launchIntent)

                val remaining = widgetData.getString("widget_kcal_remaining", "--") ?: "--"
                val goalStr = widgetData.getString("widget_kcal_goal", "2000") ?: "2000"
                val consumedStr = widgetData.getString("widget_kcal_consumed", "0") ?: "0"

                val goal = goalStr.toIntOrNull() ?: 2000
                val consumed = consumedStr.toIntOrNull() ?: 0

                val progressPercent = if (goal > 0) {
                    ((consumed.toFloat() / goal.toFloat()) * 100).toInt().coerceIn(0, 100)
                } else {
                    0
                }

                setTextViewText(R.id.widget_kcal_value, remaining)
                setProgressBar(R.id.widget_circular_progress, 100, progressPercent, false)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
