package com.adarshkumarverma.wishperlog

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.plugin.common.MethodChannel

/**
 * Receives captured note broadcasts from OverlayForegroundService via
 * LocalBroadcastManager (same bus that broadcastCapture now uses — ISSUE-03).
 *
 * Delivery priority:
 *  1. Forward to live Flutter engine via MethodChannel.
 *  2. Start BackgroundNoteService (headless Flutter) if engine is dead.
 *  3. Persist to SharedPreferences as a last-resort safety net.
 *     Notes are drained on next app resume via MainActivity.flushPendingNotes().
 */
class NoteInputReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "NoteInputReceiver"

        /** SharedPreferences file used for the persistence safety net. */
        private const val PREFS_PENDING = "wishperlog_pending_notes"

        fun register(context: Context, receiver: NoteInputReceiver) {
            LocalBroadcastManager.getInstance(context).registerReceiver(
                receiver,
                IntentFilter(OverlayForegroundService.ACTION_NOTE_CAPTURED)
            )
        }

        fun unregister(context: Context, receiver: NoteInputReceiver) {
            try {
                LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver)
            } catch (e: Exception) {
                Log.w(TAG, "unregister: already unregistered", e)
            }
        }

        /**
         * Persists a note to SharedPreferences so it is never silently dropped.
         * The note is cleared by MainActivity.flushPendingNotes() only AFTER
         * the Flutter engine confirms receipt via MethodChannel.Result.success.
         */
        fun persistPending(context: Context, text: String, source: String) {
            val key  = System.currentTimeMillis().toString()
            val prefs = context.getSharedPreferences(PREFS_PENDING, Context.MODE_PRIVATE)
            prefs.edit()
                .putString("${key}_text",   text)
                .putString("${key}_source", source)
                .apply()
            Log.d(TAG, "Persisted pending note key=$key (len=${text.length})")
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != OverlayForegroundService.ACTION_NOTE_CAPTURED) return

        val text   = intent.getStringExtra(OverlayForegroundService.EXTRA_TEXT)   ?: return
        val source = intent.getStringExtra(OverlayForegroundService.EXTRA_SOURCE) ?: "voice_overlay"

        // Always persist first — cleared below only after confirmed delivery.
        val pendingKey = System.currentTimeMillis().toString()
        val prefs = context.getSharedPreferences(PREFS_PENDING, Context.MODE_PRIVATE)
        prefs.edit()
            .putString("${pendingKey}_text",   text)
            .putString("${pendingKey}_source", source)
            .apply()

        val channel = FlutterEngineHolder.channel
        if (channel != null) {
            channel.invokeMethod(
                "captureNote",
                mapOf("text" to text, "source" to source),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        // Confirmed delivery — remove from safety-net store.
                        prefs.edit()
                            .remove("${pendingKey}_text")
                            .remove("${pendingKey}_source")
                            .apply()
                        Log.d(TAG, "captureNote delivered via live engine (len=${text.length})")
                    }
                    override fun error(code: String, msg: String?, details: Any?) {
                        Log.e(TAG, "captureNote error ($code) — starting BackgroundNoteService")
                        BackgroundNoteService.start(context, text, source)
                        // Safety-net entry stays until BackgroundNoteService completes.
                    }
                    override fun notImplemented() {
                        Log.e(TAG, "captureNote notImplemented — starting BackgroundNoteService")
                        BackgroundNoteService.start(context, text, source)
                    }
                }
            )
        } else {
            Log.w(TAG, "Engine dead — starting BackgroundNoteService")
            BackgroundNoteService.start(context, text, source)
        }
    }
}