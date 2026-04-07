package com.adarshkumarverma.wishperlog

import android.Manifest
import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.text.InputType
import android.text.TextUtils
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean

class OverlayForegroundService : Service() {

    companion object {
        private const val TAG = "OverlayForegroundSvc"
        const val ACTION_NOTE_CAPTURED = "com.wishperlog.NOTE_CAPTURED"
        const val EXTRA_TEXT = "extra_text"
        const val EXTRA_SOURCE = "extra_source"
        const val SOURCE_VOICE = "voice_overlay"
        const val SOURCE_TEXT = "text_overlay"

        // Overlay user-configurable settings
        private const val PREF_BUBBLE_ALPHA = "overlay_bubble_alpha"
        private const val PREF_BUBBLE_GROW = "overlay_bubble_grow"
        private const val PREF_STT_LANGUAGE = "overlay_stt_language"
        private const val PREF_STT_PREFER_OFFLINE = "overlay_stt_prefer_offline"
        private const val DEFAULT_ALPHA = 0.85f
        private const val DEFAULT_GROW = true

        @Volatile
        private var instance: java.lang.ref.WeakReference<OverlayForegroundService>? = null

        /** Called by MainActivity when Flutter pushes a CaptureUiController state change. */
        fun updateIsland(state: String, message: String?) {
            instance?.get()?.handleIslandUpdate(state, message)
        }

        /** Called by Flutter after a note has been saved — shows saved pill with category. */
        fun notifySaved(title: String, category: String, collection: String = "notes") {
            instance?.get()?.handleSavedNotification(title, category, collection)
        }

        fun notifyBackgroundSaved(title: String, category: String) {
            instance?.get()?.handleSavedNotification(title, category, "notes")
        }

        /**
         * Dismisses the island immediately. Called by BackgroundNoteService when
         * the headless engine finishes but has no title (e.g., empty transcript).
         */
        fun dismissIslandFromBackground() {
            instance?.get()?.dismissIsland()
        }
        /** Called by MainActivity to live-update settings without restart. */
        fun applySettings(alpha: Float, grow: Boolean) {
            instance?.get()?.handleApplySettings(alpha, grow)
        }
    }

    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var bannerView: View? = null
    private var islandView: View? = null
    private lateinit var bubbleParams: WindowManager.LayoutParams
    private var longPressRunnable: Runnable? = null
    private var longPressTriggered = false

    private var speechRecognizer: SpeechRecognizer? = null
    private var isRecording = false
    private var isResettingAfterError = false
    private var lastCaptureAttemptMs: Long = 0
    private val CAPTURE_COOLDOWN_MS = 800L
    private var lastPartialTranscript: String = ""
    private val handler = Handler(Looper.getMainLooper())
    private var islandDismissRunnable: Runnable? = null
    private val noteReceiver = NoteInputReceiver()
    private var receiverRegistered = false

    // Safety: track whether stopListening was called so we ignore spurious onResults
    private var stopListeningCalled = false
    private var isUserHolding = false
    private var restartListenRunnable: Runnable? = null
    private var lastRecognizerIntent: Intent? = null
    
    // Audio focus management for out-of-app recording
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var recordingStartTime: Long = 0
    private var bubbleGrowEnabled: Boolean = DEFAULT_GROW

    // ─── Bubble views ───────────────────────────────────────────────────────────
    private var bubbleIcon: ImageView? = null
    private var bubbleBackground: GradientDrawable? = null

    override fun onBind(intent: Intent): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startForeground(1, createNotification())
        instance = java.lang.ref.WeakReference(this)
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        // Own our receiver, independent from Application lifecycle.
        NoteInputReceiver.register(this, noteReceiver)
        receiverRegistered = true
        createBubble()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: service running in foreground")
        return START_STICKY
    }

    // ─── Notification ───────────────────────────────────────────────────────────

    private fun createNotification(): Notification {
        val channelId = "wishperlog_overlay"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, "WishperLog Overlay",
                NotificationManager.IMPORTANCE_MIN
            )
            (getSystemService(NotificationManager::class.java)).createNotificationChannel(channel)
        }
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("WishperLog")
            .setContentText("Tap & hold to capture. Double-tap to type.")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .build()
    }

    private fun vibrate(ms: Long = 40) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vm.defaultVibrator.vibrate(
                    VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE)
                )
            } else {
                @Suppress("DEPRECATION")
                (getSystemService(VIBRATOR_SERVICE) as? Vibrator)
                    ?.vibrate(VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE))
            }
        } catch (_: Exception) {}
    }

    // ─── Floating Bubble ────────────────────────────────────────────────────────

    private fun dp(value: Float): Int = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, value, resources.displayMetrics
    ).toInt()

    private fun sp(value: Float): Float = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_SP, value, resources.displayMetrics
    )

    private fun overlayType() =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE

    private fun displayWidth(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
            windowManager.currentWindowMetrics.bounds.width()
        else
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.width
    }

    private fun statusBarHeight(): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val insets = windowManager.currentWindowMetrics.windowInsets
                    .getInsets(android.view.WindowInsets.Type.statusBars())
                if (insets.top > 0) return insets.top
            } catch (_: Exception) {}
        }
        val resourceId = resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (resourceId > 0) resources.getDimensionPixelSize(resourceId) else dp(28f)
    }

    private fun createBubble() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !android.provider.Settings.canDrawOverlays(this)) {
            stopSelf(); return
        }

        val prefs = getSharedPreferences("com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
        val bubbleAlpha = prefs.getFloat(PREF_BUBBLE_ALPHA, DEFAULT_ALPHA).coerceIn(0.3f, 1f)
        bubbleGrowEnabled = prefs.getBoolean(PREF_BUBBLE_GROW, DEFAULT_GROW)

        bubbleParams = WindowManager.LayoutParams(
            dp(54f), dp(54f),
            overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = prefs.getInt("overlay_x", displayWidth() - dp(64f))
            y = prefs.getInt("overlay_y", 200)
        }

        val bubble = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            colors = intArrayOf(Color.parseColor("#6366F1"), Color.parseColor("#4F46E5"))
            orientation = GradientDrawable.Orientation.TL_BR
            setStroke(dp(1.5f), Color.parseColor("#4DFFFFFF"))
        }
        bubbleBackground = bubble

        val frame = FrameLayout(this).apply {
            background = bubble
            elevation = dp(8f).toFloat()
            alpha = bubbleAlpha
        }

        val icon = ImageView(this).apply {
            setImageDrawable(ContextCompat.getDrawable(this@OverlayForegroundService, android.R.drawable.ic_btn_speak_now))
            setColorFilter(Color.WHITE)
            layoutParams = FrameLayout.LayoutParams(dp(22f), dp(22f), Gravity.CENTER)
            scaleType = ImageView.ScaleType.FIT_CENTER
        }
        bubbleIcon = icon
        frame.addView(icon)

        var initX = 0; var initY = 0
        var initTX = 0f; var initTY = 0f
        var isDragging = false
        val dragThresholdPx = 8
        val longPressDelayMs = 350L
        val doubleTapTimeoutMs = 280L
        var lastTapUpAt = 0L

        frame.setOnTouchListener { v, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    if (isRecording) return@setOnTouchListener true
                    initX = bubbleParams.x; initY = bubbleParams.y
                    initTX = event.rawX; initTY = event.rawY
                    isDragging = false
                    longPressTriggered = false
                    isUserHolding = false
                    longPressRunnable?.let { handler.removeCallbacks(it) }
                    longPressRunnable = Runnable {
                        longPressTriggered = true
                        isUserHolding = true
                        if (bubbleGrowEnabled) {
                            bubbleView?.animate()
                                ?.scaleX(1.22f)?.scaleY(1.22f)
                                ?.setDuration(180)?.start()
                        }
                        startVoiceCapture()
                    }
                    handler.postDelayed(longPressRunnable!!, longPressDelayMs)
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - initTX).toInt()
                    val dy = (event.rawY - initTY).toInt()
                    if (longPressTriggered || isRecording) {
                        return@setOnTouchListener true
                    }

                    if (Math.abs(dx) > dragThresholdPx || Math.abs(dy) > dragThresholdPx) {
                        isDragging = true
                        longPressRunnable?.let { handler.removeCallbacks(it) }
                    }
                    if (isDragging) {
                        bubbleParams.x = initX + dx
                        bubbleParams.y = initY + dy
                        windowManager.updateViewLayout(bubbleView, bubbleParams)
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    bubbleView?.animate()?.scaleX(1f)?.scaleY(1f)?.setDuration(120)?.start()
                    longPressRunnable?.let { handler.removeCallbacks(it) }
                    isUserHolding = false
                    restartListenRunnable?.let { handler.removeCallbacks(it) }
                    restartListenRunnable = null
                    val cx = bubbleParams.x + v.width / 2
                    if (isDragging) {
                        val snapX = if (cx > displayWidth() / 2) displayWidth() - dp(64f) else 0
                        val minY = statusBarHeight() + dp(8f)
                        bubbleParams.x = snapX
                        bubbleParams.y = bubbleParams.y.coerceAtLeast(minY)
                        windowManager.updateViewLayout(bubbleView, bubbleParams)
                        prefs.edit()
                            .putInt("overlay_x", bubbleParams.x)
                            .putInt("overlay_y", bubbleParams.y)
                            .apply()
                    } else if (!longPressTriggered) {
                        val now = event.eventTime
                        if (now - lastTapUpAt <= doubleTapTimeoutMs) {
                            showTextInputBanner()
                            lastTapUpAt = 0L
                        } else {
                            lastTapUpAt = now
                        }
                    }

                    if (longPressTriggered) {
                        if (isRecording) {
                            stopVoiceCapture()
                        }
                    }
                    longPressTriggered = false
                    longPressRunnable = null
                    true
                }
                MotionEvent.ACTION_CANCEL -> {
                    bubbleView?.animate()?.scaleX(1f)?.scaleY(1f)?.setDuration(120)?.start()
                    longPressRunnable?.let { handler.removeCallbacks(it) }
                    longPressRunnable = null
                    longPressTriggered = false
                    isUserHolding = false
                    restartListenRunnable?.let { handler.removeCallbacks(it) }
                    restartListenRunnable = null
                    if (isRecording) {
                        stopVoiceCapture()
                    }
                    true
                }
                else -> false
            }
        }

        bubbleView = frame
        windowManager.addView(frame, bubbleParams)
    }

    private var pulseAnimator: ObjectAnimator? = null

    private fun startVoiceCapture() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            handler.post { startVoiceCapture() }
            return
        }

        val now = System.currentTimeMillis()
        if (now - lastCaptureAttemptMs < CAPTURE_COOLDOWN_MS) {
            Log.d(TAG, "startVoiceCapture: cooldown active, ignoring")
            return
        }
        lastCaptureAttemptMs = now

        if (isRecording || isResettingAfterError) return

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            Log.w(TAG, "startVoiceCapture: RECORD_AUDIO missing, asking Flutter to request permission")
            FlutterEngineHolder.channel?.invokeMethod("promptMicrophonePermission", null)
            showPersistentIsland(
                "Microphone permission required",
                Color.parseColor("#EF4444"),
                android.R.drawable.ic_lock_idle_lock
            )
            scheduleIslandDismiss(2500L)
            return
        }

        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            Log.e(TAG, "startVoiceCapture: speech recognition not available")
            showPersistentIsland(
                "Speech recognition unavailable",
                Color.parseColor("#EF4444"),
                android.R.drawable.ic_dialog_alert
            )
            scheduleIslandDismiss(2000)
            return
        }

        Log.d(TAG, "startVoiceCapture: starting recognizer")
        isRecording = true
        stopListeningCalled = false
        lastPartialTranscript = ""
        recordingStartTime = System.currentTimeMillis()
        requestAudioFocus()

        // Tell Flutter the island should show recording state.
        FlutterEngineHolder.channel?.invokeMethod("notifyRecordingStarted", null)

        // Show animated "Listening..." on the native island immediately (works even when app is off-screen)
        showPersistentIsland(
            "Listening...",
            Color.parseColor("#6366F1"),
            android.R.drawable.ic_btn_speak_now
        )

        // Visual: bubble pulses red
        bubbleBackground?.colors = intArrayOf(Color.parseColor("#EF4444"), Color.parseColor("#991B1B"))
        bubbleIcon?.setImageDrawable(ContextCompat.getDrawable(this, android.R.drawable.presence_audio_online))
        bubbleIcon?.setColorFilter(Color.WHITE)

        pulseAnimator = ObjectAnimator.ofPropertyValuesHolder(
            bubbleView,
            PropertyValuesHolder.ofFloat("scaleX", 1f, 1.15f),
            PropertyValuesHolder.ofFloat("scaleY", 1f, 1.15f)
        ).apply {
            duration = 600
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.REVERSE
            start()
        }

        releaseSpeechRecognizer()
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        Log.d(TAG, "startVoiceCapture: SpeechRecognizer created")
        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onResults(results: Bundle?) {
                // Only discard if we were never recording in the first place.
                if (!stopListeningCalled && !isRecording) return
                Log.d(TAG, "onResults: received final recognition results")
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                val text = (matches?.firstOrNull()?.trim()).orEmpty().ifEmpty {
                    lastPartialTranscript.trim()
                }
                isRecording = false
                resetBubble()
                releaseSpeechRecognizer()
                if (text.isNotEmpty()) {
                    // Show "Classifying..." on the native island BEFORE forwarding to Flutter
                    // This ensures the user sees processing state even when app is off-screen
                    showPersistentIsland(
                        "Classifying...",
                        Color.parseColor("#7C3AED"),
                        android.R.drawable.ic_popup_sync
                    )
                    // CRITICAL FIX #4: Safety-net — if BackgroundNoteService never replies
                    // (e.g. Gemini fails, network dead), dismiss the island after 40s so it
                    // never gets permanently stuck on "Classifying...".
                    scheduleIslandDismiss(40_000L)
                    broadcastCapture(text, SOURCE_VOICE)
                    FlutterEngineHolder.channel?.invokeMethod("notifyRecordingStopped", null)
                } else {
                    dismissIsland()
                    FlutterEngineHolder.channel?.invokeMethod("notifyRecordingFailed", null)
                }
            }

            override fun onError(error: Int) {
                Log.e(TAG, "onError: code=$error (${recognizerErrorToString(error)})")

                // On some ROMs, manual stop often returns ERROR_NO_MATCH even when
                // partial speech exists. Salvage that partial transcript.
                val recoverableError =
                    error == SpeechRecognizer.ERROR_NO_MATCH ||
                    error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT ||
                    error == SpeechRecognizer.ERROR_CLIENT

                // Keep recording alive for hold-to-record if recognizer closes transiently.
                if (isUserHolding && isRecording && !stopListeningCalled && recoverableError) {
                    Log.w(TAG, "onError: recoverable during hold, restarting recognizer")
                    restartListenRunnable?.let { handler.removeCallbacks(it) }
                    restartListenRunnable = Runnable {
                        if (!isUserHolding || !isRecording || stopListeningCalled) {
                            return@Runnable
                        }
                        val restartIntent = lastRecognizerIntent ?: return@Runnable
                        try {
                            releaseSpeechRecognizer()
                            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this@OverlayForegroundService)
                            speechRecognizer?.setRecognitionListener(this)
                            speechRecognizer?.startListening(restartIntent)
                        } catch (e: Exception) {
                            Log.e(TAG, "onError: restart after recoverable error failed", e)
                        }
                    }
                    handler.postDelayed(restartListenRunnable!!, 150)
                    return
                }

                val fallbackText = lastPartialTranscript.trim()
                if (stopListeningCalled && recoverableError && fallbackText.isNotEmpty()) {
                    Log.d(TAG, "onError: salvaging partial transcript (${fallbackText.length} chars)")
                    isRecording = false
                    stopListeningCalled = false
                    isResettingAfterError = false
                    resetBubble()
                    releaseSpeechRecognizer()
                    showPersistentIsland(
                        "Classifying...",
                        Color.parseColor("#7C3AED"),
                        android.R.drawable.ic_popup_sync
                    )
                    scheduleIslandDismiss(40_000L) // safety net
                    broadcastCapture(fallbackText, SOURCE_VOICE)
                    FlutterEngineHolder.channel?.invokeMethod("notifyRecordingStopped", null)
                    return
                }

                isResettingAfterError = true
                isRecording = false
                stopListeningCalled = false // reset for the next capture session
                resetBubble()
                dismissIsland()
                FlutterEngineHolder.channel?.invokeMethod("notifyRecordingFailed", null)
                releaseSpeechRecognizer()
                handler.postDelayed({ isResettingAfterError = false }, 1000L)
            }

            override fun onReadyForSpeech(params: Bundle?) {
                Log.d(TAG, "onReadyForSpeech")
            }
            override fun onBeginningOfSpeech() {
                Log.d(TAG, "onBeginningOfSpeech")
            }
            override fun onRmsChanged(rmsdB: Float) {
                // Only log verbose in debug builds — this fires ~30x/second
                // Log.v(TAG, "onRmsChanged: $rmsdB")
            }
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {
                Log.d(TAG, "onEndOfSpeech")
                // Keep listening while the user is still holding.
                if (isUserHolding && isRecording && !stopListeningCalled) {
                    Log.d(TAG, "onEndOfSpeech: user still holding, restarting recognizer")
                    restartListenRunnable?.let { handler.removeCallbacks(it) }
                    restartListenRunnable = Runnable {
                        if (!isUserHolding || !isRecording || stopListeningCalled) {
                            return@Runnable
                        }
                        val restartIntent = lastRecognizerIntent ?: return@Runnable
                        try {
                            releaseSpeechRecognizer()
                            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this@OverlayForegroundService)
                            speechRecognizer?.setRecognitionListener(this)
                            speechRecognizer?.startListening(restartIntent)
                        } catch (e: Exception) {
                            Log.e(TAG, "onEndOfSpeech: restart failed", e)
                        }
                    }
                    handler.postDelayed(restartListenRunnable!!, 120)
                }
            }
            override fun onPartialResults(partialResults: Bundle?) {
                val packet = partialResults
                    ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    ?.firstOrNull()
                if (!packet.isNullOrEmpty()) {
                    val merged = mergeTranscript(lastPartialTranscript, packet).take(240)
                    lastPartialTranscript = merged
                    val display = merged.takeLast(90)

                    // Update native island with live transcript
                    showPersistentIsland(
                        display,
                        Color.parseColor("#6366F1"),
                        android.R.drawable.ic_btn_speak_now
                    )
                    FlutterEngineHolder.channel?.invokeMethod(
                        "notifyRecordingTranscript",
                        hashMapOf("text" to merged)
                    )
                }
            }
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            val prefs = getSharedPreferences("com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
            val sttLanguage = prefs.getString(PREF_STT_LANGUAGE, Locale.getDefault().toLanguageTag())
                ?: Locale.getDefault().toLanguageTag()
            val preferOffline = prefs.getBoolean(PREF_STT_PREFER_OFFLINE, false)

            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, sttLanguage)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, sttLanguage)
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, preferOffline)
            putExtra("android.speech.extra.DICTATION_MODE", true)
            // Keep the recognizer alive longer from a background service context.
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 1000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 8000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 5000L)
        }
        Log.d(TAG, "startVoiceCapture: startListening invoked")
        try {
            lastRecognizerIntent = intent
            speechRecognizer?.startListening(intent)
            vibrate(30)
        } catch (e: Exception) {
            Log.e(TAG, "startVoiceCapture: failed to start listening", e)
            isRecording = false
            resetBubble()
            dismissIsland()
        }
    }

    private fun stopVoiceCapture() {
        val elapsed = System.currentTimeMillis() - recordingStartTime
        Log.d(TAG, "stopVoiceCapture: stopping current session (elapsed=${elapsed}ms)")
        stopListeningCalled = true
        releaseAudioFocus()
        restartListenRunnable?.let { handler.removeCallbacks(it) }
        restartListenRunnable = null
        isUserHolding = false
        try {
            speechRecognizer?.stopListening()
        } catch (e: Exception) {
            Log.w(TAG, "stopVoiceCapture: stopListening failed", e)
            resetBubble()
            dismissIsland()
            releaseSpeechRecognizer()
            FlutterEngineHolder.channel?.invokeMethod("notifyRecordingFailed", null)
        }
    }

    private fun releaseSpeechRecognizer() {
        try {
            try {
                speechRecognizer?.cancel()
            } catch (_: Exception) {}
            speechRecognizer?.destroy()
        } catch (e: Exception) {
            Log.w(TAG, "releaseSpeechRecognizer: destroy failed", e)
        } finally {
            speechRecognizer = null
        }
    }

    private fun recognizerErrorToString(error: Int): String {
        return when (error) {
            SpeechRecognizer.ERROR_AUDIO -> "ERROR_AUDIO"
            SpeechRecognizer.ERROR_CLIENT -> "ERROR_CLIENT"
            SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "ERROR_INSUFFICIENT_PERMISSIONS"
            SpeechRecognizer.ERROR_NETWORK -> "ERROR_NETWORK"
            SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "ERROR_NETWORK_TIMEOUT"
            SpeechRecognizer.ERROR_NO_MATCH -> "ERROR_NO_MATCH"
            SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "ERROR_RECOGNIZER_BUSY"
            SpeechRecognizer.ERROR_SERVER -> "ERROR_SERVER"
            SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "ERROR_SPEECH_TIMEOUT"
            else -> "UNKNOWN_ERROR"
        }
    }

    private fun mergeTranscript(existing: String, incoming: String): String {
        val prev = existing.replace(Regex("\\s+"), " ").trim()
        val next = incoming.replace(Regex("\\s+"), " ").trim()
        if (next.isEmpty()) return prev
        if (prev.isEmpty()) return next
        if (next.equals(prev, ignoreCase = true)) return prev

        if (next.startsWith(prev, ignoreCase = true)) return next
        if (prev.startsWith(next, ignoreCase = true)) {
            // Recognizer occasionally emits shortened packets; keep richer text.
            return if (next.length < (prev.length * 0.65f)) prev else next
        }

        val maxOverlap = minOf(prev.length, next.length)
        for (len in maxOverlap downTo 1) {
            if (prev.takeLast(len).equals(next.take(len), ignoreCase = true)) {
                return (prev + next.drop(len)).replace(Regex("\\s+"), " ").trim()
            }
        }

        // If packet length is similar, it is likely a refreshed hypothesis.
        val ratio = next.length.toFloat() / prev.length.toFloat()
        if (ratio in 0.7f..1.4f) return next

        return "$prev $next".replace(Regex("\\s+"), " ").trim()
    }

    private fun resetBubble() {
        isRecording = false
        isUserHolding = false
        restartListenRunnable?.let { handler.removeCallbacks(it) }
        restartListenRunnable = null
        pulseAnimator?.cancel()
        bubbleView?.scaleX = 1f
        bubbleView?.scaleY = 1f
        pulseAnimator = null
        releaseAudioFocus()

        bubbleBackground?.colors = intArrayOf(Color.parseColor("#6366F1"), Color.parseColor("#4F46E5"))
        bubbleIcon?.setImageDrawable(ContextCompat.getDrawable(this, android.R.drawable.ic_btn_speak_now))
        bubbleIcon?.setColorFilter(Color.WHITE)
    }

    // ─── Text Input Banner ────────────────────────────────────────────────────

    private fun showTextInputBanner() {
        if (bannerView != null) return
        dismissBanner()

        val bannerParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            y = dp(8f)
        }

        val bg = GradientDrawable().apply {
            cornerRadius = dp(20f).toFloat()
            colors = intArrayOf(Color.parseColor("#1E1B4B"), Color.parseColor("#312E81"))
            gradientType = GradientDrawable.LINEAR_GRADIENT
            orientation = GradientDrawable.Orientation.TL_BR
            setStroke(dp(1f), Color.parseColor("#7C3AED"))
        }

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16f), dp(12f), dp(16f), dp(12f))
            background = bg
            elevation = dp(16f).toFloat()
        }

        val header = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val title = TextView(this).apply {
            text = "Quick Note"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            setTypeface(null, Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }

        val closeBtn = TextView(this).apply {
            text = "✕"
            setTextColor(Color.parseColor("#94A3B8"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            setPadding(dp(8f), dp(4f), 0, dp(4f))
            setOnClickListener { dismissBanner() }
        }

        header.addView(title)
        header.addView(closeBtn)

        val input = EditText(this).apply {
            hint = "What's on your mind?"
            setHintTextColor(Color.parseColor("#64748B"))
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            background = GradientDrawable().apply {
                cornerRadius = dp(12f).toFloat()
                setColor(Color.parseColor("#1F2937"))
            }
            setPadding(dp(12f), dp(10f), dp(12f), dp(10f))
            inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
            maxLines = 4
            setImeOptions(EditorInfo.IME_ACTION_DONE)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { topMargin = dp(10f) }
        }

        val sendBtn = TextView(this).apply {
            text = "Send →"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            setTypeface(null, Typeface.BOLD)
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                cornerRadius = dp(12f).toFloat()
                colors = intArrayOf(Color.parseColor("#7C3AED"), Color.parseColor("#4F46E5"))
            }
            setPadding(dp(16f), dp(10f), dp(16f), dp(10f))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { topMargin = dp(10f) }
            setOnClickListener {
                val text = input.text.toString().trim()
                if (text.isNotEmpty()) {
                    showPersistentIsland(
                        "Classifying...",
                        Color.parseColor("#7C3AED"),
                        android.R.drawable.ic_popup_sync
                    )
                    scheduleIslandDismiss(40_000L)
                    broadcastCapture(text, SOURCE_TEXT)
                }
                dismissBanner()
            }
        }

        layout.addView(header)
        layout.addView(input)
        layout.addView(sendBtn)

        bannerView = layout
        windowManager.addView(layout, bannerParams)

        handler.postDelayed({
            input.requestFocus()
            val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
            bannerParams.flags = bannerParams.flags and WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE.inv()
            windowManager.updateViewLayout(bannerView, bannerParams)
            imm.showSoftInput(input, InputMethodManager.SHOW_IMPLICIT)
        }, 100)
    }

    private fun dismissBanner() {
        bannerView?.let {
            try { windowManager.removeView(it) } catch (_: Exception) {}
        }
        bannerView = null
    }

    // ─── Dynamic Island Pill ────────────────────────────────────────────────────

    /**
     * Called by Flutter via MainActivity when CaptureUiState changes.
     * Works only when the app is in the foreground.
     */
    private fun handleIslandUpdate(state: String, message: String?) {
        when (state) {
            "recording" -> {
                val display = if (message.isNullOrBlank()) "Listening..."
                              else message.take(55)
                showPersistentIsland(
                    display,
                    Color.parseColor("#6366F1"),
                    android.R.drawable.ic_btn_speak_now
                )
                // No auto-dismiss for recording — dismissed when state changes
            }
            "processing" -> {
                val label = if (message.isNullOrEmpty()) "Classifying..." else "via $message..."
                showPersistentIsland(
                    label,
                    Color.parseColor("#7C3AED"),
                    android.R.drawable.ic_popup_sync
                )
            }
            "saved" -> {
                val label = message?.take(45) ?: "Saved"
                showPersistentIsland(
                    label,
                    Color.parseColor("#10B981"),
                    android.R.drawable.checkbox_on_background
                )
                scheduleIslandDismiss(2500L)
            }
            else -> {
                dismissIsland()
            }
        }
    }

    /**
     * Called directly by Flutter after background save completes.
     * This is the key path that works even when the app is in background.
     */
    private fun handleSavedNotification(title: String, category: String, _collection: String) {
        handler.post {
            vibrate(60)
            val categoryLabel = when (category) {
                "tasks" -> "Task"
                "reminders" -> "Reminder"
                "ideas" -> "Idea"
                "followUp" -> "Follow-up"
                "journal" -> "Journal"
                else -> "Note"
            }
            val categoryIcon = when (category) {
                "tasks" -> android.R.drawable.checkbox_on_background
                "reminders" -> android.R.drawable.ic_lock_idle_alarm
                "ideas" -> android.R.drawable.ic_menu_edit
                "followUp" -> android.R.drawable.ic_media_rew
                "journal" -> android.R.drawable.ic_menu_agenda
                else -> android.R.drawable.ic_menu_info_details
            }
            val line1 = categoryLabel
            val line2 = title
            showPersistentIslandTwoLine(line1, line2, Color.parseColor("#10B981"), categoryIcon)
            scheduleIslandDismiss(2500L)
        }
    }

    private fun handleApplySettings(alpha: Float, grow: Boolean) {
        handler.post {
            val normalizedAlpha = alpha.coerceIn(0.3f, 1f)
            bubbleView?.alpha = normalizedAlpha
            bubbleGrowEnabled = grow
            val prefs = getSharedPreferences("com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
            prefs.edit()
                .putFloat(PREF_BUBBLE_ALPHA, normalizedAlpha)
                .putBoolean(PREF_BUBBLE_GROW, grow)
                .apply()
        }
    }

    private fun showPersistentIslandTwoLine(
        line1: String,
        line2: String,
        accentColor: Int,
        iconRes: Int
    ) {
        handler.post {
            islandDismissRunnable?.let(handler::removeCallbacks)
            val fixedWidth = islandFixedWidth()

            val existing = islandView
            if (existing is FrameLayout && existing.childCount > 0) {
                val child0 = existing.getChildAt(0)
                if (child0 is LinearLayout && child0.childCount >= 2) {
                    val textStack = child0.getChildAt(1)
                    if (textStack is LinearLayout && textStack.childCount >= 2) {
                        (existing.layoutParams as? WindowManager.LayoutParams)?.let { lp ->
                            if (lp.width != fixedWidth) {
                                lp.width = fixedWidth
                                windowManager.updateViewLayout(existing, lp)
                            }
                        }
                        val iconView = child0.getChildAt(0)
                        if (iconView is ImageView) {
                            iconView.setImageDrawable(
                                ContextCompat.getDrawable(this@OverlayForegroundService, iconRes)
                            )
                            iconView.setColorFilter(accentColor)
                        }
                        (textStack.getChildAt(0) as? TextView)?.text = line1
                        (textStack.getChildAt(1) as? TextView)?.text = line2
                        (existing.background as? GradientDrawable)?.setStroke(dp(1.5f), accentColor)
                        return@post
                    }
                }
                removeIslandNow()
            }

            removeIslandNow()

            val islandParams = WindowManager.LayoutParams(
                fixedWidth,
                WindowManager.LayoutParams.WRAP_CONTENT,
                overlayType(),
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                y = statusBarHeight() + dp(2f)
            }

            val container = FrameLayout(this)
            
            // Background gradient with accent glow
            val bgGradient = GradientDrawable().apply {
                cornerRadius = dp(20f).toFloat()
                colors = intArrayOf(
                    Color.parseColor("#0F172A"),
                    Color.parseColor("#1E293B")
                )
                orientation = GradientDrawable.Orientation.LEFT_RIGHT
                setStroke(dp(1.5f), accentColor)
                alpha = 240
            }
            container.background = bgGradient
            container.elevation = dp(16f).toFloat()

            // Content: icon + (line1 + line2)
            val contentLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    setPadding(dp(16f), dp(10f), dp(16f), dp(10f))
                }
                setPadding(dp(16f), dp(10f), dp(16f), dp(10f))
                gravity = Gravity.CENTER_VERTICAL
            }

            val iconView = ImageView(this).apply {
                setImageDrawable(ContextCompat.getDrawable(this@OverlayForegroundService, iconRes))
                setColorFilter(accentColor)
                layoutParams = LinearLayout.LayoutParams(dp(18f), dp(18f)).apply {
                    rightMargin = dp(10f)
                }
            }

            val textStack = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
            }

            textStack.addView(TextView(this).apply {
                text = line1
                setTextColor(accentColor)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
                setTypeface(Typeface.DEFAULT_BOLD)
                maxLines = 1
                ellipsize = TextUtils.TruncateAt.END
            })

            textStack.addView(TextView(this).apply {
                text = line2
                setTextColor(Color.parseColor("#E2E8F0"))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                setTypeface(Typeface.DEFAULT_BOLD)
                maxLines = 1
                ellipsize = TextUtils.TruncateAt.END
                setPadding(0, dp(3f), 0, 0)
            })

            contentLayout.addView(iconView)
            contentLayout.addView(textStack)

            container.addView(contentLayout)
            islandView = container
            try {
                windowManager.addView(container, islandParams)
            } catch (e: Exception) {
                Log.w(TAG, "showPersistentIslandTwoLine failed: $e")
            }
        }
    }

    private fun showPersistentIsland(message: String, accentColor: Int, iconRes: Int) {
        if (message.isBlank()) return
        handler.post {
            islandDismissRunnable?.let(handler::removeCallbacks)
            val fixedWidth = islandFixedWidth()

            val existingPill = islandView
            if (existingPill is FrameLayout) {
                val child0 = existingPill.getChildAt(0)
                if (child0 is LinearLayout && child0.childCount >= 2) {
                    val maybeText = child0.getChildAt(1)
                    if (maybeText is TextView) {
                        (existingPill.layoutParams as? WindowManager.LayoutParams)?.let { lp ->
                            if (lp.width != fixedWidth) {
                                lp.width = fixedWidth
                                windowManager.updateViewLayout(existingPill, lp)
                            }
                        }
                        val iconView = child0.getChildAt(0)
                        if (iconView is ImageView) {
                            iconView.setImageDrawable(
                                ContextCompat.getDrawable(this@OverlayForegroundService, iconRes)
                            )
                            iconView.setColorFilter(accentColor)
                        }
                        maybeText.text = message
                        (existingPill.background as? GradientDrawable)?.setStroke(dp(1.5f), accentColor)
                        return@post
                    }
                }
                removeIslandNow()
            }

            removeIslandNow()

            val islandParams = WindowManager.LayoutParams(
                fixedWidth,
                WindowManager.LayoutParams.WRAP_CONTENT,
                overlayType(),
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                y = statusBarHeight() + dp(2f)
            }

            val container = FrameLayout(this)
            
            // Premium gradient background with glow effect
            val bgGradient = GradientDrawable().apply {
                cornerRadius = dp(24f).toFloat()
                colors = intArrayOf(
                    Color.parseColor("#1E1B4B"),
                    Color.parseColor("#312E81") 
                )
                orientation = GradientDrawable.Orientation.TOP_BOTTOM
                setStroke(dp(1.5f), accentColor)
                alpha = 245
            }
            container.background = bgGradient
            container.elevation = dp(16f).toFloat()

            // Icon + main text with padding
            val row = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(16f), dp(10f), dp(16f), dp(10f))
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                )
            }

            val iconView = ImageView(this).apply {
                setImageDrawable(ContextCompat.getDrawable(this@OverlayForegroundService, iconRes))
                setColorFilter(accentColor)
                layoutParams = LinearLayout.LayoutParams(dp(18f), dp(18f)).apply {
                    rightMargin = dp(10f)
                }
            }

            val textView = TextView(this).apply {
                text = message
                setTextColor(Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                setTypeface(Typeface.DEFAULT_BOLD)
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                maxLines = 1
                ellipsize = TextUtils.TruncateAt.END
                alpha = 0.95f
            }

            row.addView(iconView)
            row.addView(textView)
            container.addView(row)
            islandView = container
            try {
                windowManager.addView(container, islandParams)
                
                // Smooth fade-in animation
                textView.alpha = 0f
                textView.animate()
                    .alpha(0.95f)
                    .setDuration(200)
                    .start()
            } catch (e: Exception) {
                Log.w(TAG, "showPersistentIsland: addView failed: $e")
            }
        }
    }

    // ─── Audio Focus Management ─────────────────────────────────────────────────────
    
    private fun requestAudioFocus() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && audioManager != null) {
                val audioAttr = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build()
                audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                    .setAudioAttributes(audioAttr)
                    .setAcceptsDelayedFocusGain(false)
                    .setOnAudioFocusChangeListener { focusChange ->
                        Log.d(TAG, "onAudioFocusChange: $focusChange")
                        when (focusChange) {
                            AudioManager.AUDIOFOCUS_LOSS -> {
                                if (isRecording) handler.post { stopVoiceCapture() }
                            }
                            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT,
                            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                                Log.d(TAG, "onAudioFocusChange: transient loss - ignoring")
                            }
                            AudioManager.AUDIOFOCUS_GAIN -> {
                                Log.d(TAG, "onAudioFocusChange: focus regained")
                            }
                        }
                    }
                    .build()
                val result = audioManager?.requestAudioFocus(audioFocusRequest!!)
                if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                    Log.d(TAG, "requestAudioFocus: GRANTED")
                } else {
                    Log.w(TAG, "requestAudioFocus: DENIED or DELAYED")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "requestAudioFocus: exception", e)
        }
    }
    
    private fun releaseAudioFocus() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && audioFocusRequest != null) {
                audioManager?.abandonAudioFocusRequest(audioFocusRequest!!)
                audioFocusRequest = null
                Log.d(TAG, "releaseAudioFocus: released")
            }
        } catch (e: Exception) {
            Log.e(TAG, "releaseAudioFocus: exception", e)
        }
    }

    private fun islandFixedWidth(): Int {
        val screenWidth = displayWidth()
        val maxWidth = dp(360f)
        return minOf((screenWidth * 0.85f).toInt(), maxWidth)
    }

    private fun removeIslandNow() {
        islandView?.let {
            try {
                windowManager.removeView(it)
            } catch (_: Exception) {}
        }
        islandView = null
    }

    private fun scheduleIslandDismiss(delayMs: Long) {
        islandDismissRunnable?.let(handler::removeCallbacks)
        islandDismissRunnable = Runnable { dismissIsland() }
        handler.postDelayed(islandDismissRunnable!!, delayMs)
    }

    private fun dismissIsland() {
        handler.post {
            islandDismissRunnable?.let(handler::removeCallbacks)
            islandDismissRunnable = null
            
            // Smooth fade-out animation before removing
            islandView?.let {
                it.animate()
                    .alpha(0f)
                    .setDuration(150)
                    .withEndAction { removeIslandNow() }
                    .start()
            } ?: removeIslandNow()
        }
    }

    // ─── Broadcast to Flutter ───────────────────────────────────────────────────

    private fun sendCaptureViaLocalBroadcast(text: String, source: String) {
        val intent = Intent(ACTION_NOTE_CAPTURED).apply {
            putExtra(EXTRA_TEXT, text)
            putExtra(EXTRA_SOURCE, source)
        }
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
    }

    private fun broadcastCapture(text: String, source: String) {
        val channel = FlutterEngineHolder.channel
        if (channel != null) {
            // Prefer direct channel path when engine is alive.
            handler.post {
                val completed = AtomicBoolean(false)
                // Some devices never invoke MethodChannel callbacks while app is backgrounded.
                // If we don't receive an ack quickly, force fallback so island does not get stuck.
                val fallbackRunnable = Runnable {
                    if (completed.compareAndSet(false, true)) {
                        Log.w(TAG, "broadcastCapture: direct call timeout, falling back")
                        sendCaptureViaLocalBroadcast(text, source)
                    }
                }
                handler.postDelayed(fallbackRunnable, 1200)

                channel.invokeMethod("captureNote", mapOf("text" to text, "source" to source),
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            if (completed.compareAndSet(false, true)) {
                                handler.removeCallbacks(fallbackRunnable)
                                Log.d(TAG, "broadcastCapture: captureNote forwarded directly")
                            }
                        }

                        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                            if (completed.compareAndSet(false, true)) {
                                handler.removeCallbacks(fallbackRunnable)
                                Log.w(TAG, "broadcastCapture: direct call failed ($errorCode), falling back")
                                sendCaptureViaLocalBroadcast(text, source)
                            }
                        }

                        override fun notImplemented() {
                            if (completed.compareAndSet(false, true)) {
                                handler.removeCallbacks(fallbackRunnable)
                                Log.w(TAG, "broadcastCapture: direct method not implemented, falling back")
                                sendCaptureViaLocalBroadcast(text, source)
                            }
                        }
                    }
                )
            }
        } else {
            // Fallback when Flutter engine is not alive.
            sendCaptureViaLocalBroadcast(text, source)
        }
    }

    // ─── Lifecycle ──────────────────────────────────────────────────────────────

    override fun onDestroy() {
        if (receiverRegistered) {
            NoteInputReceiver.unregister(this, noteReceiver)
            receiverRegistered = false
        }
        releaseAudioFocus()
        releaseSpeechRecognizer()
        bubbleView?.let { try { windowManager.removeView(it) } catch (_: Exception) {} }
        dismissBanner()
        dismissIsland()
        instance = null
        super.onDestroy()
    }
}