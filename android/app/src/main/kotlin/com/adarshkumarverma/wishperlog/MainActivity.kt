package com.adarshkumarverma.wishperlog

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "wishperlog/overlay"
    private val REQUEST_RECORD_AUDIO = 4242
    private var pendingMicPermissionResult: MethodChannel.Result? = null

    companion object {
        private const val TAG = "MainActivity"
    }

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode =
        FlutterActivityLaunchConfigs.BackgroundMode.transparent

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        FlutterEngineHolder.channel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {

                // ── Overlay lifecycle ────────────────────────────────────────
                "show" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                        !Settings.canDrawOverlays(this)) {
                        result.error("PERMISSION_DENIED", "Overlay permission not granted", null)
                    } else {
                        val i = Intent(this, OverlayForegroundService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                            startForegroundService(i) else startService(i)
                        result.success(null)
                    }
                }
                "hide" -> {
                    stopService(Intent(this, OverlayForegroundService::class.java))
                    result.success(null)
                }

                // ── Permissions ──────────────────────────────────────────────
                "checkPermission" -> result.success(
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                        Settings.canDrawOverlays(this) else true
                )
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        startActivity(
                            Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName"))
                        )
                    }
                    result.success(null)
                }
                "requestMicrophonePermission" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                        == PackageManager.PERMISSION_GRANTED) {
                        result.success(true)
                    } else {
                        pendingMicPermissionResult = result
                        ActivityCompat.requestPermissions(
                            this, arrayOf(Manifest.permission.RECORD_AUDIO), REQUEST_RECORD_AUDIO
                        )
                    }
                }

                // ── Island state sync (Flutter → Native) ─────────────────────
                "updateIslandState" -> {
                    val state   = call.argument<String>("state")   ?: "idle"
                    val message = call.argument<String>("message")
                    OverlayForegroundService.updateIsland(state, message)
                    result.success(null)
                }
                "notifySaved" -> {
                    val title      = call.argument<String>("title")      ?: ""
                    val category   = call.argument<String>("category")   ?: "general"
                    val collection = call.argument<String>("collection") ?: "notes"
                    OverlayForegroundService.notifySaved(title, category, collection)
                    result.success(null)
                }

                // ── Overlay appearance settings ───────────────────────────────
                "getOverlaySettings" -> {
                    val prefs = getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
                    result.success(mapOf(
                        "alpha"     to prefs.getFloat("overlay_bubble_alpha", 0.85f),
                        "growOnHold" to prefs.getBoolean("overlay_bubble_grow", true)
                    ))
                }
                "updateOverlaySettings" -> {
                    val alpha = (call.argument<Double>("alpha") ?: 0.85).toFloat()
                    val grow  = call.argument<Boolean>("growOnHold") ?: true
                    getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
                        .edit()
                        .putFloat("overlay_bubble_alpha", alpha)
                        .putBoolean("overlay_bubble_grow", grow)
                        .apply()
                    OverlayForegroundService.applySettings(alpha, grow)
                    result.success(null)
                }

                // ── Speech settings ───────────────────────────────────────────
                "getSpeechSettings" -> {
                    val prefs = getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
                    result.success(mapOf(
                        "language"     to (prefs.getString("overlay_stt_language", "en-US") ?: "en-US"),
                        "preferOffline" to prefs.getBoolean("overlay_stt_prefer_offline", false)
                    ))
                }
                "updateSpeechSettings" -> {
                    val lang    = call.argument<String>("language")      ?: "en-US"
                    val offline = call.argument<Boolean>("preferOffline") ?: false
                    getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
                        .edit()
                        .putString("overlay_stt_language", lang)
                        .putBoolean("overlay_stt_prefer_offline", offline)
                        .apply()
                    result.success(null)
                }
                "downloadSpeechLanguagePack" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_LOCALE_SETTINGS)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    } catch (_: Exception) {}
                    result.success(null)
                }

                // ── Flush pending notes saved while engine was dead ───────────
                "flushPendingNotes" -> {
                    flushPendingNotes(channel)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        // Auto-flush pending notes every time app comes to foreground
        flushPendingNotes(channel)
    }

    /**
     * Reads notes that were persisted to SharedPreferences while the Flutter
     * engine was dead (e.g. app killed during overlay recording) and re-injects
     * them into Flutter for normal Isar + AI + Firestore processing.
     */
    private fun flushPendingNotes(channel: MethodChannel) {
        val prefs = getSharedPreferences("wishperlog_pending_notes", Context.MODE_PRIVATE)
        val keys  = prefs.all.keys.filter { it.endsWith("_text") }.sorted()
        if (keys.isEmpty()) return

        Log.d(TAG, "flushPendingNotes: found ${keys.size} pending notes")
        val editor = prefs.edit()

        for (k in keys) {
            val base   = k.removeSuffix("_text")
            val text   = prefs.getString("${base}_text",   null) ?: continue
            val source = prefs.getString("${base}_source", "voice_overlay") ?: "voice_overlay"
            editor.remove("${base}_text").remove("${base}_source")
            channel.invokeMethod("captureNote", mapOf("text" to text, "source" to source))
        }
        editor.apply()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_RECORD_AUDIO) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingMicPermissionResult?.success(granted)
            pendingMicPermissionResult = null
        }
    }

    override fun onDestroy() {
        // Do NOT null the channel here: BackgroundNoteService might still need it.
        super.onDestroy()
    }
}