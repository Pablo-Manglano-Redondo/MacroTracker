package com.epsait.macrotracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class MacroTrackerHabitsWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.macrotracker_habits_widget,
            ).apply {
                val launchIntent =
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_container, launchIntent)

                val focus = widgetData.getString("widget_focus_label", "Rest") ?: "Rest"
                val steps = widgetData.getString("widget_steps_progress", "0 / 0") ?: "0 / 0"
                val sleep = widgetData.getString("widget_sleep_progress", "0 / 0h") ?: "0 / 0h"

                setTextViewText(R.id.widget_focus_value, focus)
                setTextViewText(R.id.widget_steps_value, steps)
                setTextViewText(R.id.widget_sleep_value, sleep)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
