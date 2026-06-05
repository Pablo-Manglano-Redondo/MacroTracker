package com.epsait.macrotracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class MacroTrackerQuickActionsWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.macrotracker_quick_actions_widget,
            ).apply {
                // Apply icon tint colors via setInt (android:tint not supported in RemoteViews)
                setInt(R.id.widget_icon_water, "setColorFilter", Color.parseColor("#3B82F6"))
                setInt(R.id.widget_icon_scan, "setColorFilter", Color.parseColor("#A855F7"))

                // Setup Water Intent
                val waterIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                    data = Uri.parse("macrotracker://add_water")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                val waterPendingIntent = PendingIntent.getActivity(
                    context,
                    1001,
                    waterIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_button_water, waterPendingIntent)

                // Setup Scan Intent
                val scanIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                    data = Uri.parse("macrotracker://scan")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                val scanPendingIntent = PendingIntent.getActivity(
                    context,
                    1002,
                    scanIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_button_scan, scanPendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
