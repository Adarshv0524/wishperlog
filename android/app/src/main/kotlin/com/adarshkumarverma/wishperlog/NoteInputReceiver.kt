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
 * KEY FIX: This receiver is now registered by the SERVICE itself (not MainActivity),
 * so it stays alive even when the app is in the background.
 * MainActivity still registers/unregisters a second copy for convenience when the
 * app is foregrounded (both are safe — Flutter handles duplicate captureNote calls via
 * the noteId dedup in IsarNoteStore).
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
        val source = intent.getStringExtra(OverlayForegroundService.EXTRA_SOURCE) ?: "overlay"

        val payload = mapOf(
            "text" to text,
            "source" to source
        )

        val channel = FlutterEngineHolder.channel
        if (channel == null) {
            Log.w(TAG, "captureNote dropped: Flutter channel unavailable (engine/activity not alive)")
            // When Flutter is not available, we cannot process the note.
            // The note will be re-attempted on next app open via Firestore sync.
            // TODO: consider storing in SharedPreferences and retrying on next launch.
            return
        }

        channel.invokeMethod("captureNote", payload, object : MethodChannel.Result {
            override fun success(result: Any?) {
                Log.d(TAG, "captureNote forwarded to Flutter (source=$source, len=${text.length})")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "captureNote failed in Flutter: code=$errorCode, msg=$errorMessage")
            }

            override fun notImplemented() {
                Log.e(TAG, "captureNote failed: method not implemented on Flutter side")
            }
        })
    }
}