package com.adarshkumarverma.wishperlog

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        val prefs = context.getSharedPreferences(
            "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
        val enabled = prefs.getBoolean("overlay_v2.enabled", true)
        if (!enabled) return
        Log.d("BootReceiver", "Boot completed - restarting overlay service")
        val serviceIntent = Intent(context, OverlayForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            context.startForegroundService(serviceIntent)
        else
            context.startService(serviceIntent)
    }
}
