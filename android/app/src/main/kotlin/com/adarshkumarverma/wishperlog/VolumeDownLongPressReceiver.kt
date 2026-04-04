package com.adarshkumarverma.wishperlog

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.MethodChannel

object HardwareMethodChannelHolder {
    var channel: MethodChannel? = null
}

class VolumeDownLongPressReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action != ACTION_VOLUME_DOWN_LONG_PRESS) {
            return
        }

        val phase = intent.getStringExtra(EXTRA_PHASE) ?: "unknown"
        Log.d(TAG, "Volume-down long press event phase: $phase")

        HardwareMethodChannelHolder.channel?.invokeMethod(
            "volumeDownLongPress",
            mapOf("phase" to phase),
        )
    }

    companion object {
        const val ACTION_VOLUME_DOWN_LONG_PRESS =
            "com.adarshkumarverma.wishperlog.ACTION_VOLUME_DOWN_LONG_PRESS"
        const val EXTRA_PHASE = "phase"
        private const val TAG = "WishperlogHardware"
    }
}
