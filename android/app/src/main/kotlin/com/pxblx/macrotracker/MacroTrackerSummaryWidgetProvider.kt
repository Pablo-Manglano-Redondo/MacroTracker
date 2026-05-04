package com.pxblx.macrotracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class MacroTrackerSummaryWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.macrotracker_summary_widget,
            ).apply {
                val launchIntent =
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_container, launchIntent)

                setTextViewText(
                    R.id.widget_kcal_value,
                    widgetData.getString("widget_kcal_remaining", "--") ?: "--",
                )
                setTextViewText(
                    R.id.widget_carbs_value,
                    widgetData.getString("widget_carbs_progress", "0/0") ?: "0/0",
                )
                setTextViewText(
                    R.id.widget_fats_value,
                    widgetData.getString("widget_fat_progress", "0/0") ?: "0/0",
                )
                setTextViewText(
                    R.id.widget_protein_value,
                    widgetData.getString("widget_protein_progress", "0/0") ?: "0/0",
                )
                setTextViewText(
                    R.id.widget_water_value,
                    widgetData.getString("widget_water_progress", "0/0L") ?: "0/0L",
                )
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
