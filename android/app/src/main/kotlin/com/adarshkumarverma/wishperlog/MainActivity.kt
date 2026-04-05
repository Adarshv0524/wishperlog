package com.adarshkumarverma.wishperlog

import android.Manifest
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
    private val noteReceiver = NoteInputReceiver()
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
                    OverlayForegroundService.notifySaved(title, category)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Register overlay note receiver (secondary - in case service receiver misses it)
        NoteInputReceiver.register(this, noteReceiver)
    }

    override fun onDestroy() {
        NoteInputReceiver.unregister(this, noteReceiver)
        FlutterEngineHolder.channel = null
        super.onDestroy()
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