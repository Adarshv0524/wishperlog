package com.adarshkumarverma.wishperlog

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
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

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
        return FlutterActivityLaunchConfigs.BackgroundMode.transparent
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        // Store channel globally so NoteInputReceiver can access it from any context
        FlutterEngineHolder.channel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "show" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                        result.error("PERMISSION_DENIED", "Overlay permission not granted", null)
                    } else {
                        val serviceIntent = Intent(this, OverlayForegroundService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                            startForegroundService(serviceIntent)
                        else
                            startService(serviceIntent)
                        result.success(null)
                    }
                }
                "hide" -> {
                    stopService(Intent(this, OverlayForegroundService::class.java))
                    result.success(null)
                }
                "checkPermission" -> {
                    result.success(
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                            Settings.canDrawOverlays(this)
                        else true
                    )
                }
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
                    }
                    result.success(null)
                }
                "requestMicrophonePermission" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
                        result.success(true)
                    } else {
                        if (pendingMicPermissionResult != null) {
                            result.error("REQUEST_IN_PROGRESS", "Microphone permission request already in progress", null)
                        } else {
                            pendingMicPermissionResult = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.RECORD_AUDIO),
                                REQUEST_RECORD_AUDIO
                            )
                        }
                    }
                }
                "updateIslandState" -> {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<String, Any?> ?: emptyMap()
                    val state = args["state"] as? String ?: "idle"
                    val message = args["message"] as? String
                    OverlayForegroundService.updateIsland(state, message)
                    result.success(null)
                }
                // KEY NEW METHOD: Flutter calls this after a background capture note is saved
                // so the native island can show the category + title pill
                "notifySaved" -> {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<String, Any?> ?: emptyMap()
                    val title = args["title"] as? String ?: "Saved"
                    val category = args["category"] as? String ?: "general"
                    val collection = args["collection"] as? String ?: "notes"
                    OverlayForegroundService.notifySaved(title, category, collection)
                    result.success(null)
                }
                "updateOverlaySettings" -> {
                    val alpha = (call.argument<Double>("alpha") ?: 0.85).toFloat()
                    val grow = call.argument<Boolean>("growOnHold") ?: true
                    val normalizedAlpha = alpha.coerceIn(0.3f, 1f)
                    val prefs = getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences",
                        Context.MODE_PRIVATE
                    )
                    prefs.edit()
                        .putFloat("overlay_bubble_alpha", normalizedAlpha)
                        .putBoolean("overlay_bubble_grow", grow)
                        .apply()
                    OverlayForegroundService.applySettings(normalizedAlpha, grow)
                    result.success(null)
                }
                "getOverlaySettings" -> {
                    val prefs = getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences",
                        Context.MODE_PRIVATE
                    )
                    val alpha = prefs.getFloat("overlay_bubble_alpha", 0.85f).toDouble()
                    val grow = prefs.getBoolean("overlay_bubble_grow", true)
                    result.success(mapOf("alpha" to alpha, "growOnHold" to grow))
                }
                "updateSpeechSettings" -> {
                    val language = call.argument<String>("language") ?: "en-US"
                    val preferOffline = call.argument<Boolean>("preferOffline") ?: false
                    val prefs = getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences",
                        Context.MODE_PRIVATE
                    )
                    prefs.edit()
                        .putString("overlay_stt_language", language)
                        .putBoolean("overlay_stt_prefer_offline", preferOffline)
                        .apply()
                    result.success(null)
                }
                "getSpeechSettings" -> {
                    val prefs = getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences",
                        Context.MODE_PRIVATE
                    )
                    val language = prefs.getString("overlay_stt_language", "en-US") ?: "en-US"
                    val preferOffline = prefs.getBoolean("overlay_stt_prefer_offline", false)
                    result.success(mapOf("language" to language, "preferOffline" to preferOffline))
                }
                "downloadSpeechLanguagePack" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_VOICE_INPUT_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        })
                        result.success(true)
                    } catch (_: Exception) {
                        try {
                            startActivity(Intent(Settings.ACTION_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            })
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Could not open speech settings", e.message)
                        }
                    }
                }
                "drainPendingNotes" -> {
                    val prefs = getSharedPreferences("wishperlog_pending_notes", Context.MODE_PRIVATE)
                    val all = prefs.all
                    val textKeys = all.keys.filter { it.endsWith("_text") }
                    val channel2 = FlutterEngineHolder.channel
                    textKeys.forEach { textKey ->
                        val sourceKey = textKey.replace("_text", "_source")
                        val text = prefs.getString(textKey, null)
                        val src = prefs.getString(sourceKey, "voice_overlay") ?: "voice_overlay"
                        if (text != null && channel2 != null) {
                            channel2.invokeMethod("captureNote", mapOf("text" to text, "source" to src))
                            prefs.edit().remove(textKey).remove(sourceKey).apply()
                        }
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        drainPendingNotes()
    }

    private fun drainPendingNotes() {
        val prefs = getSharedPreferences("wishperlog_pending_notes", Context.MODE_PRIVATE)
        val all = prefs.all
        if (all.isEmpty()) return

        val channel = FlutterEngineHolder.channel ?: return
        val keys = all.keys.filter { it.endsWith("_text") }
        keys.forEach { textKey ->
            val sourceKey = textKey.replace("_text", "_source")
            val text = prefs.getString(textKey, null) ?: return@forEach
            val source = prefs.getString(sourceKey, "voice_overlay") ?: "voice_overlay"

            channel.invokeMethod("captureNote", mapOf("text" to text, "source" to source))
            prefs.edit().remove(textKey).remove(sourceKey).apply()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    override fun onFlutterUiNoLongerDisplayed() {
        super.onFlutterUiNoLongerDisplayed()
        // Don't null the channel here either; foreground service may still need it.
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == REQUEST_RECORD_AUDIO) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingMicPermissionResult?.success(granted)
            pendingMicPermissionResult = null
        }
    }
}