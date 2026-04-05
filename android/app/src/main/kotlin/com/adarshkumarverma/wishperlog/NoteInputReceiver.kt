package com.adarshkumarverma.wishperlog

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.plugin.common.MethodChannel

/**
 * Receives captured note text from OverlayForegroundService and
 * forwards it to Flutter via MethodChannel — WITHOUT opening the app.
 *
 * Registered once at the Application level (see WishperlogApplication) so only a
 * single receiver instance handles each broadcast.
 */
class NoteInputReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "NoteInputReceiver"

        fun register(context: Context, receiver: NoteInputReceiver) {
            LocalBroadcastManager.getInstance(context)
                .registerReceiver(receiver, IntentFilter(OverlayForegroundService.ACTION_NOTE_CAPTURED))
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

        val text = intent.getStringExtra(OverlayForegroundService.EXTRA_TEXT) ?: return
        val source = intent.getStringExtra(OverlayForegroundService.EXTRA_SOURCE) ?: "voice_overlay"

        val channel = FlutterEngineHolder.channel
        if (channel == null) {
            Log.w(TAG, "captureNote: engine not alive — persisting for retry")
            persistPending(context, text, source)
            return
        }

        channel.invokeMethod("captureNote", mapOf("text" to text, "source" to source),
            object : MethodChannel.Result {
            override fun success(result: Any?) {
                Log.d(TAG, "captureNote forwarded (source=$source, len=${text.length})")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "captureNote failed: $errorCode")
                persistPending(context, text, source)
            }

            override fun notImplemented() {
                Log.e(TAG, "captureNote: notImplemented")
                persistPending(context, text, source)
            }
        })
    }

    private fun persistPending(context: Context, text: String, source: String) {
        val prefs = context.getSharedPreferences(
            "wishperlog_pending_notes", Context.MODE_PRIVATE
        )
        val key = "pending_${System.currentTimeMillis()}"
        prefs.edit()
            .putString("${key}_text", text)
            .putString("${key}_source", source)
            .apply()
    }
}