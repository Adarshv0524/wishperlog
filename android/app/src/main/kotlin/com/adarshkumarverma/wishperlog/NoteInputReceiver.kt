package com.adarshkumarverma.wishperlog

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.plugin.common.MethodChannel

/**
 * Receives captured note broadcasts from OverlayForegroundService.
 * Priority order:
 *  1. Forward to live Flutter engine via MethodChannel (zero-latency).
 *  2. Start BackgroundNoteService (headless Flutter engine) if engine is dead.
 *  3. Persist to SharedPreferences as a safety net.
 */
class NoteInputReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "NoteInputReceiver"

        fun register(context: Context, receiver: NoteInputReceiver) {
            LocalBroadcastManager.getInstance(context).registerReceiver(
                receiver, IntentFilter(OverlayForegroundService.ACTION_NOTE_CAPTURED)
            )
        }

        fun unregister(context: Context, receiver: NoteInputReceiver) {
            try {
                LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver)
            } catch (e: Exception) {
                Log.w(TAG, "unregister: already unregistered", e)
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != OverlayForegroundService.ACTION_NOTE_CAPTURED) return

        val text   = intent.getStringExtra(OverlayForegroundService.EXTRA_TEXT)   ?: return
        val source = intent.getStringExtra(OverlayForegroundService.EXTRA_SOURCE) ?: "voice_overlay"

        val channel = FlutterEngineHolder.channel
        if (channel != null) {
            channel.invokeMethod(
                "captureNote",
                mapOf("text" to text, "source" to source),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        Log.d(TAG, "captureNote forwarded via live engine (len=${text.length})")
                    }
                    override fun error(code: String, msg: String?, details: Any?) {
                        Log.e(TAG, "captureNote failed ($code) — launching BackgroundNoteService")
                        BackgroundNoteService.start(context, text, source)
                    }
                    override fun notImplemented() {
                        Log.e(TAG, "captureNote notImplemented — launching BackgroundNoteService")
                        BackgroundNoteService.start(context, text, source)
                    }
                }
            )
        } else {
            Log.w(TAG, "Engine dead — launching BackgroundNoteService")
            BackgroundNoteService.start(context, text, source)
        }
    }
}