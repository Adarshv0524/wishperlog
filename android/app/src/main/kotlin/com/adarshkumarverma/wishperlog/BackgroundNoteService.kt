package com.adarshkumarverma.wishperlog

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * Headless Flutter engine service.
 *
 * Invoked when OverlayForegroundService captures a note but the main Flutter
 * engine is not alive (app fully killed). Starts a lightweight Dart isolate via
 * [backgroundNoteCallback], forwards the raw transcript, waits for Dart to:
 *   1. Persist to Isar
 *   2. Run Gemini classification
 *   3. Sync to Firestore
 *
 * CRITICAL FIX #2:
 * When Dart signals 'done' it now passes {title, category} of the saved note.
 * BackgroundNoteService forwards this to OverlayForegroundService.notifyBackgroundSaved()
 * so the native island pill updates from "Classifying..." to the real saved state.
 * Before this fix, the island was permanently stuck on "Classifying...".
 */
class BackgroundNoteService : Service() {

    companion object {
        private const val TAG = "BackgroundNoteSvc"
        private const val CHANNEL_ID = "wishperlog_bg_note"
        private const val NOTIFICATION_ID = 9002
        const val EXTRA_TEXT = "extra_text"
        const val EXTRA_SOURCE = "extra_source"

        fun start(context: Context, text: String, source: String) {
            val i = Intent(context, BackgroundNoteService::class.java).apply {
                putExtra(EXTRA_TEXT, text)
                putExtra(EXTRA_SOURCE, source)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                context.startForegroundService(i)
            else
                context.startService(i)
        }
    }

    private var flutterEngine: FlutterEngine? = null
    private var bgChannel: MethodChannel? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startForeground(NOTIFICATION_ID, buildNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val text   = intent?.getStringExtra(EXTRA_TEXT)   ?: ""
        val source = intent?.getStringExtra(EXTRA_SOURCE) ?: "voice_overlay"

        // Fast path: main engine still alive — just forward and exit.
        val live = FlutterEngineHolder.channel
        if (live != null && text.isNotEmpty()) {
            live.invokeMethod(
                "captureNote",
                mapOf("text" to text, "source" to source),
                object : MethodChannel.Result {
                    override fun success(r: Any?)    { stopSelf() }
                    override fun error(c: String, m: String?, d: Any?) {
                        drainAndProcess(text, source)
                    }
                    override fun notImplemented()    { drainAndProcess(text, source) }
                }
            )
        } else {
            drainAndProcess(text, source)
        }
        return START_NOT_STICKY
    }

    private fun drainAndProcess(newText: String, newSource: String) {
        Log.d(TAG, "drainAndProcess: booting headless Flutter engine")
        FlutterInjector.instance().flutterLoader().startInitialization(applicationContext)
        FlutterInjector.instance().flutterLoader().ensureInitializationComplete(applicationContext, null)

        val engine = FlutterEngine(applicationContext)
        flutterEngine = engine
        GeneratedPluginRegistrant.registerWith(engine)

        bgChannel = MethodChannel(engine.dartExecutor.binaryMessenger, "wishperlog/background_notes")

        // Collect pending notes from SharedPreferences + this new note.
        val prefs   = getSharedPreferences("wishperlog_pending_notes", Context.MODE_PRIVATE)
        val pending = mutableListOf<Pair<String, String>>()
        if (newText.isNotEmpty()) pending.add(Pair(newText, newSource))

        val allKeys = prefs.all.keys.filter { it.endsWith("_text") }
        for (k in allKeys) {
            val baseKey = k.removeSuffix("_text")
            val t = prefs.getString("${baseKey}_text", null) ?: continue
            val s = prefs.getString("${baseKey}_source", "voice_overlay") ?: "voice_overlay"
            pending.add(Pair(t, s))
        }
        prefs.edit().clear().apply()

        var pendingIdx = 0

        bgChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "ready" -> {
                    result.success(null)
                    dispatchNext(pending, pendingIdx).also { pendingIdx = it }
                }
                "nextNote" -> {
                    result.success(null)
                    dispatchNext(pending, pendingIdx).also { pendingIdx = it }
                }

                // CRITICAL FIX #2:
                // Dart now sends {title, category} so we can update the island
                // from "Classifying..." to the actual saved state. Without this,
                // the pill was stuck forever when the engine was dead at capture time.
                "done" -> {
                    result.success(null)
                    val title    = call.argument<String>("title")    ?: ""
                    val category = call.argument<String>("category") ?: "general"
                    if (title.isNotEmpty()) {
                        Log.d(TAG, "done: notifying island — title='$title' category='$category'")
                        OverlayForegroundService.notifyBackgroundSaved(title, category)
                    } else {
                        Log.d(TAG, "done: no title, dismissing island")
                        OverlayForegroundService.dismissIslandFromBackground()
                    }
                    stopSelf()
                }

                else -> result.notImplemented()
            }
        }

        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "backgroundNoteCallback"
            )
        )
    }

    private fun dispatchNext(pending: List<Pair<String, String>>, idx: Int): Int {
        return if (idx < pending.size) {
            val (t, s) = pending[idx]
            bgChannel?.invokeMethod("processNote", mapOf("text" to t, "source" to s))
            idx + 1
        } else {
            bgChannel?.invokeMethod("allDone", null)
            idx
        }
    }

    override fun onDestroy() {
        flutterEngine?.destroy()
        flutterEngine = null
        bgChannel = null
        super.onDestroy()
    }

    private fun buildNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(
                CHANNEL_ID,
                "WishperLog Background Save",
                NotificationManager.IMPORTANCE_MIN
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(ch)
        }
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("WishperLog")
            .setContentText("Saving voice note…")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .build()
    }
}