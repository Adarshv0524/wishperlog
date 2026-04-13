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
import android.net.Uri
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
import android.provider.Settings
import android.text.InputType
import android.text.TextUtils
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.OvershootInterpolator
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
import java.util.Locale

/**
 * OverlayForegroundService — "God-Level" optimized overlay with:
 *  - Robust lifecycle teardown: overlay ALWAYS resets/dismisses after capture ends.
 *  - Maximum STT accuracy: LANGUAGE_MODEL_FREE_FORM, partial results, dictation mode,
 *    silence detection tuning, multi-hypothesis merging, salvage on error.
 *  - Atomic state machine preventing stuck "Classifying..." states.
 *  - Auto-dismiss safety net (40 s) with explicit idle reset path.
 *  - Minute-granularity transcript forwarding to Flutter.
 */
class OverlayForegroundService : Service() {

    // ─── Companion / static API ──────────────────────────────────────────────

    companion object {
        private const val TAG = "OverlayForegroundSvc"

        const val ACTION_NOTE_CAPTURED = "com.wishperlog.NOTE_CAPTURED"
        const val EXTRA_TEXT   = "extra_text"
        const val EXTRA_SOURCE = "extra_source"
        const val SOURCE_VOICE = "voice_overlay"
        const val SOURCE_TEXT  = "text_overlay"

        private const val PREF_BUBBLE_ALPHA      = "overlay_bubble_alpha"
        private const val PREF_BUBBLE_GROW       = "overlay_bubble_grow"
        private const val PREF_SETTINGS_JSON     = "overlay_settings_json"
        private const val PREF_STT_LANGUAGE      = "overlay_stt_language"
        private const val PREF_STT_PREFER_OFFLINE = "overlay_stt_prefer_offline"
        private const val DEFAULT_ALPHA = 0.90f
        private const val DEFAULT_GROW  = true

        // Capture cooldown — prevents double-fire on rapid gestures.
        private const val CAPTURE_COOLDOWN_MS = 900L

        // Safety-net: island will always auto-dismiss after this delay if
        // BackgroundNoteService never calls notifySaved / dismissIsland.
        private const val ISLAND_SAFETY_DISMISS_MS = 40_000L

        @Volatile
        private var instance: java.lang.ref.WeakReference<OverlayForegroundService>? = null

        fun updateIsland(state: String, message: String?) {
            instance?.get()?.handleIslandUpdate(state, message)
        }

        fun notifySaved(title: String, category: String, prefix: String = "AI", collection: String = "notes") {
            instance?.get()?.handleSavedNotification(title, category, prefix, collection)
        }

        fun notifyBackgroundSaved(title: String, category: String, prefix: String = "AI") {
            notifySaved(title, category, prefix, "notes")
        }

        /** Explicitly resets island to idle — call when empty transcript is detected. */
        fun dismissIslandFromBackground() {
            instance?.get()?.dismissIslandAndReset()
        }

        fun applySettings(settingsJson: String) {
            instance?.get()?.handleApplySettings(settingsJson)
        }

        fun applySettings(alpha: Float, grow: Boolean) {
            instance?.get()?.handleApplySettings(
                OverlayAppearanceSettings.legacy(alpha, grow).toJsonString(),
            )
        }
    }

    // ─── Views ────────────────────────────────────────────────────────────────

    private lateinit var windowManager: WindowManager
    private var bubbleView: View?  = null
    private var bannerView: View?  = null
    private var islandView: View?  = null
    private lateinit var bubbleParams: WindowManager.LayoutParams

    // Sub-views kept for direct mutation without full re-inflation.
    private var bubbleIcon:       ImageView?       = null
    private var bubbleBackground: GradientDrawable? = null
    private var islandLabel:      TextView?         = null
    private var islandBg:         GradientDrawable? = null
    private var overlaySettings   = OverlayAppearanceSettings()
    private var islandBaseColor   = Color.parseColor("#6366F1")

    // ─── STT state ────────────────────────────────────────────────────────────

    private var speechRecognizer:       SpeechRecognizer? = null
    private var lastRecognizerIntent:   Intent?           = null
    private var lastPartialTranscript:  String            = ""
    private var stopListeningCalled:    Boolean           = false
    private var isUserHolding:          Boolean           = false
    private var isRecording:            Boolean           = false
    private var isResettingAfterError:  Boolean           = false
    private var recordingStartTime:     Long              = 0L
    private var lastCaptureAttemptMs:   Long              = 0L
    private var longPressTriggered:     Boolean           = false
    private var bubbleGrowEnabled:      Boolean           = DEFAULT_GROW

    // ─── Handlers / runnables ─────────────────────────────────────────────────

    private val mainHandler         = Handler(Looper.getMainLooper())
    private var longPressRunnable:   Runnable? = null
    private var restartListenRunnable: Runnable? = null
    private var islandDismissRunnable: Runnable? = null
    private var pulseAnimator:       ObjectAnimator? = null
    private var idlePulseAnimator:   ObjectAnimator? = null

    // ─── Audio focus ─────────────────────────────────────────────────────────

    private var audioManager:      AudioManager?      = null
    private var audioFocusRequest: AudioFocusRequest? = null

    // ─── Other infra ─────────────────────────────────────────────────────────

    private val noteReceiver       = NoteInputReceiver()
    private var receiverRegistered = false

    // ─── Lifecycle ────────────────────────────────────────────────────────────

    override fun onBind(intent: Intent): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startForeground(1, buildNotification())
        instance = java.lang.ref.WeakReference(this)
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        audioManager  = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        NoteInputReceiver.register(this, noteReceiver)
        receiverRegistered = true
        createBubble()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: service alive")
        return START_STICKY
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy: performing full teardown")
        // ── CRITICAL TEARDOWN: ensure nothing leaks ──────────────────────────
        performFullReset(removeViews = true)
        if (receiverRegistered) {
            try { NoteInputReceiver.unregister(this, noteReceiver) } catch (_: Exception) {}
            receiverRegistered = false
        }
        instance = null
        super.onDestroy()
    }

    // ─── Notification ─────────────────────────────────────────────────────────

    private fun buildNotification(): Notification {
        val channelId = "wishperlog_overlay"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(
                channelId, "WishperLog Overlay",
                NotificationManager.IMPORTANCE_MIN
            ).apply { description = "Floating note-capture bubble" }
            getSystemService(NotificationManager::class.java).createNotificationChannel(ch)
        }
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("WishperLog")
            .setContentText("Hold bubble to record • Double-tap to type")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setSilent(true)
            .build()
    }

    // ─── Dimension helpers ────────────────────────────────────────────────────

    private fun dp(v: Float) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, resources.displayMetrics).toInt()
    private fun sp(v: Float) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, v, resources.displayMetrics)

    private fun overlayType() =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE

    private fun displayWidth(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
            windowManager.currentWindowMetrics.bounds.width()
        else @Suppress("DEPRECATION") windowManager.defaultDisplay.width

    private fun statusBarHeight(): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val insets = windowManager.currentWindowMetrics.windowInsets
                    .getInsets(android.view.WindowInsets.Type.statusBars())
                if (insets.top > 0) return insets.top
            } catch (_: Exception) {}
        }
        val id = resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (id > 0) resources.getDimensionPixelSize(id) else dp(28f)
    }

    // ─── Bubble creation ──────────────────────────────────────────────────────

    private fun createBubble() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !android.provider.Settings.canDrawOverlays(this)) {
            stopSelf(); return
        }

        val prefs = getSharedPreferences("com.adarshkumarverma.wishperlog_preferences", MODE_PRIVATE)
        val storedSettings = prefs.getString(PREF_SETTINGS_JSON, null)
        overlaySettings = if (storedSettings.isNullOrBlank()) {
            OverlayAppearanceSettings.legacy(
                prefs.getFloat(PREF_BUBBLE_ALPHA, DEFAULT_ALPHA),
                prefs.getBoolean(PREF_BUBBLE_GROW, DEFAULT_GROW),
            )
        } else {
            OverlayAppearanceSettings.fromJson(storedSettings)
        }
        val bubbleAlpha = overlaySettings.alpha.coerceIn(0.3f, 1f)
        bubbleGrowEnabled = overlaySettings.growEnabled

        bubbleParams = WindowManager.LayoutParams(
            dp(54f), dp(54f), overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = prefs.getInt("overlay_x", displayWidth() - dp(64f))
            y = prefs.getInt("overlay_y", 200)
        }

        val bg = buildBubbleDrawable(overlaySettings)
        bubbleBackground = bg

        val frame = FrameLayout(this).apply {
            background = bg
            elevation  = dp(8f).toFloat()
            alpha      = bubbleAlpha
        }

        val icon = ImageView(this).apply {
            setImageDrawable(ContextCompat.getDrawable(this@OverlayForegroundService, android.R.drawable.ic_btn_speak_now))
            setColorFilter(Color.WHITE)
            layoutParams = FrameLayout.LayoutParams(dp(22f), dp(22f), Gravity.CENTER)
            scaleType    = ImageView.ScaleType.FIT_CENTER
        }
        bubbleIcon = icon
        frame.addView(icon)

        // Touch gesture state
        var initX = 0; var initY = 0
        var initTX = 0f; var initTY = 0f
        var isDragging       = false
        var lastTapUpAt      = 0L
        val dragThresholdPx  = 8
        val longPressDelayMs = 350L
        val doubleTapTimeout = 280L

        frame.setOnTouchListener { v, event ->
            synchronized(this) {
                when (event.actionMasked) {
                    MotionEvent.ACTION_DOWN -> {
                        if (isRecording) return@setOnTouchListener true
                        initX = bubbleParams.x; initY = bubbleParams.y
                        initTX = event.rawX; initTY = event.rawY
                        isDragging = false; longPressTriggered = false; isUserHolding = false
                        longPressRunnable?.let { mainHandler.removeCallbacks(it) }
                        longPressRunnable = Runnable {
                            synchronized(this) {
                                longPressTriggered = true; isUserHolding = true
                                if (bubbleGrowEnabled) frame.animate().scaleX(1.22f).scaleY(1.22f).setDuration(180).start()
                                startVoiceCapture()
                            }
                        }
                        mainHandler.postDelayed(longPressRunnable!!, longPressDelayMs)
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initTX).toInt()
                        val dy = (event.rawY - initTY).toInt()
                        if (longPressTriggered || isRecording) return@setOnTouchListener true
                        if (Math.abs(dx) > dragThresholdPx || Math.abs(dy) > dragThresholdPx) {
                            isDragging = true
                            longPressRunnable?.let { mainHandler.removeCallbacks(it) }
                        }
                        if (isDragging) {
                            val newX = initX + dx
                            val newY = initY + dy
                            if (bubbleParams.x != newX || bubbleParams.y != newY) {
                                bubbleParams.x = newX; bubbleParams.y = newY
                                windowManager.updateViewLayout(bubbleView, bubbleParams)
                            }
                        }
                        true
                    }
                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                        frame.animate().scaleX(1f).scaleY(1f).setDuration(120).start()
                        longPressRunnable?.let { mainHandler.removeCallbacks(it) }
                        longPressRunnable = null; longPressTriggered = false
                        restartListenRunnable?.let { mainHandler.removeCallbacks(it) }
                        restartListenRunnable = null
                        if (isRecording) {
                            isUserHolding = false   // clear AFTER stop so onEndOfSpeech sees correct state
                            stopVoiceCapture()
                        } else {
                            isUserHolding = false
                        }
                        if (isDragging) {
                            val cx = bubbleParams.x + v.width / 2
                            val snapX = if (cx > displayWidth() / 2) displayWidth() - dp(64f) else 0
                            val newY = bubbleParams.y.coerceAtLeast(statusBarHeight() + dp(8f))
                            if (bubbleParams.x != snapX || bubbleParams.y != newY) {
                                bubbleParams.x = snapX
                                bubbleParams.y = newY
                                windowManager.updateViewLayout(bubbleView, bubbleParams)
                                prefs.edit().putInt("overlay_x", bubbleParams.x).putInt("overlay_y", bubbleParams.y).apply()
                            }
                        } else if (!longPressTriggered) {
                            val now = event.eventTime
                            if (now - lastTapUpAt <= doubleTapTimeout) {
                                showTextInputBanner()
                                lastTapUpAt = 0L
                            } else {
                                lastTapUpAt = now
                            }
                        }
                        true
                    }
                    else -> false
                }
            }
        }

        bubbleView = frame
        windowManager.addView(frame, bubbleParams)
        startIdleBubblePulse()
    }

    // ─── Voice capture ────────────────────────────────────────────────────────

    private fun startVoiceCapture() {
        if (Looper.myLooper() != Looper.getMainLooper()) { mainHandler.post { startVoiceCapture() }; return }

        val now = System.currentTimeMillis()
        if (now - lastCaptureAttemptMs < CAPTURE_COOLDOWN_MS) return
        lastCaptureAttemptMs = now

        if (isRecording || isResettingAfterError) return

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            FlutterEngineHolder.channel?.invokeMethod("promptMicrophonePermission", null)
            openMicrophonePermissionSettings()
            showIsland("Microphone permission required", Color.parseColor("#EF4444"), android.R.drawable.ic_lock_idle_lock)
            scheduleIslandDismiss(2500L)
            return
        }

        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            showIsland("Speech recognition unavailable", Color.parseColor("#EF4444"), android.R.drawable.ic_dialog_alert)
            scheduleIslandDismiss(2000)
            return
        }

        isRecording = true; stopListeningCalled = false; lastPartialTranscript = ""
        recordingStartTime = System.currentTimeMillis()
        requestAudioFocus()
        FlutterEngineHolder.channel?.invokeMethod("notifyRecordingStarted", null)
        stopIdleBubblePulse()
        showIsland("Listening...", Color.parseColor("#6366F1"), android.R.drawable.ic_btn_speak_now)

        // Bubble → red pulse
        bubbleBackground?.colors = intArrayOf(Color.parseColor("#EF4444"), Color.parseColor("#991B1B"))
        bubbleIcon?.setImageDrawable(ContextCompat.getDrawable(this, android.R.drawable.presence_audio_online))
        bubbleIcon?.setColorFilter(Color.WHITE)
        pulseAnimator = ObjectAnimator.ofPropertyValuesHolder(
            bubbleView,
            PropertyValuesHolder.ofFloat("scaleX", 1f, 1.15f),
            PropertyValuesHolder.ofFloat("scaleY", 1f, 1.15f)
        ).apply { duration = 600; repeatCount = ObjectAnimator.INFINITE; repeatMode = ObjectAnimator.REVERSE; start() }

        releaseSpeechRecognizer()
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        speechRecognizer?.setRecognitionListener(buildRecognitionListener())

        // ── ACCURACY-OPTIMISED intent ─────────────────────────────────────────
        // Key flags that push accuracy toward "keyboard-grade":
        //  • LANGUAGE_MODEL_FREE_FORM  — natural, non-command speech.
        //  • EXTRA_MAX_RESULTS = 5    — gives the merge algo more candidates.
        //  • EXTRA_PARTIAL_RESULTS     — live display + fallback if server cuts.
        //  • DICTATION_MODE            — keeps recognizer alive for long speech.
        //  • Silence lengths tuned for natural pauses (not keyword commands).
        val prefs = getSharedPreferences("com.adarshkumarverma.wishperlog_preferences", MODE_PRIVATE)
        val lang  = prefs.getString(PREF_STT_LANGUAGE, Locale.getDefault().toLanguageTag()) ?: "en-US"
        val offline = prefs.getBoolean(PREF_STT_PREFER_OFFLINE, false)

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,   RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS,      5)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE,  packageName)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS,  true)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE,         lang)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, lang)
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE,   offline)
            // Dictation mode keeps the recognizer open across natural pauses.
            putExtra("android.speech.extra.DICTATION_MODE",   true)
            // Noise suppression hint (Samsung / Google Recorder honour this).
            putExtra("android.speech.extra.ENABLE_NOISE_SUPPRESSION", true)
            // Silence thresholds tuned for note-taking (longer pauses OK).
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS,                  1_000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS,         10_000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 6_000L)
        }

        lastRecognizerIntent = intent
        try {
            speechRecognizer?.startListening(intent)
            vibrate(30)
        } catch (e: Exception) {
            Log.e(TAG, "startListening failed", e)
            dismissIslandAndReset()
        }
    }

    private fun buildRecognitionListener(): RecognitionListener = object : RecognitionListener {

        override fun onReadyForSpeech(params: Bundle?)   { Log.d(TAG, "onReadyForSpeech") }
        override fun onBeginningOfSpeech()               { Log.d(TAG, "onBeginningOfSpeech") }
        override fun onRmsChanged(rmsdB: Float)          { /* high-frequency, skip logging */ }
        override fun onBufferReceived(buffer: ByteArray?){ }
        override fun onEvent(type: Int, params: Bundle?) { }

        override fun onPartialResults(partialResults: Bundle?) {
            val packet = partialResults
                ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                ?.firstOrNull() ?: return
            if (packet.isBlank()) return

            val merged  = mergeTranscript(lastPartialTranscript, packet).take(300)
            lastPartialTranscript = merged
            val display = merged.takeLast(90)

            showIsland(display, Color.parseColor("#6366F1"), android.R.drawable.ic_btn_speak_now)
            FlutterEngineHolder.channel?.invokeMethod("notifyRecordingTranscript", hashMapOf("text" to merged))
        }

        override fun onEndOfSpeech() {
            Log.d(TAG, "onEndOfSpeech — user holding=$isUserHolding")
            if (isUserHolding && isRecording && !stopListeningCalled) restartRecognizer(this)
        }

        override fun onResults(results: Bundle?) {
            if (!stopListeningCalled && !isRecording) return

            // Pick highest-confidence result; fall back to first or partial.
            val matches     = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            val confidences = results?.getFloatArray(SpeechRecognizer.CONFIDENCE_SCORES)

            val bestText = if (!matches.isNullOrEmpty() && confidences != null && confidences.isNotEmpty()) {
                val bestIdx = confidences.indices.maxByOrNull { confidences[it] } ?: 0
                matches.getOrNull(bestIdx)?.trim().orEmpty()
            } else {
                matches?.firstOrNull()?.trim().orEmpty()
            }.ifEmpty { lastPartialTranscript.trim() }

            // Keep recording active while the user is still holding the bubble.
            if (isUserHolding && isRecording && !stopListeningCalled) {
                if (bestText.isNotEmpty()) {
                    lastPartialTranscript = mergeTranscript(lastPartialTranscript, bestText).take(500)
                    showIsland(lastPartialTranscript.takeLast(90), Color.parseColor("#6366F1"), android.R.drawable.ic_btn_speak_now)
                    FlutterEngineHolder.channel?.invokeMethod(
                        "notifyRecordingTranscript",
                        hashMapOf("text" to lastPartialTranscript)
                    )
                }
                restartRecognizer(this)
                return
            }

            finaliseCapture(bestText)
        }

        override fun onError(error: Int) {
            Log.e(TAG, "onError: ${recognizerErrorToString(error)}")

            val recoverable = error == SpeechRecognizer.ERROR_NO_MATCH ||
                              error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT ||
                              error == SpeechRecognizer.ERROR_CLIENT

            // Restart while user holds during transient errors.
            if (isUserHolding && isRecording && !stopListeningCalled && recoverable) {
                Log.w(TAG, "onError: recoverable during hold — restarting")
                restartRecognizer(this)
                return
            }

            // Salvage partial if stop was triggered and we have something.
            val fallback = lastPartialTranscript.trim()
            if (stopListeningCalled && recoverable && fallback.isNotEmpty()) {
                Log.d(TAG, "onError: salvaging partial '${fallback.take(40)}'")
                finaliseCapture(fallback)
                return
            }

            // Nothing to save — full dismissal.
            dismissIslandAndReset()
            FlutterEngineHolder.channel?.invokeMethod("notifyRecordingFailed", null)
        }
    }

    /**
     * Called when we have final text (or empty). Handles the complete
     * post-recording teardown so it's always consistent.
     *
     * LIFECYCLE GUARANTEE: After this method returns, isRecording == false,
     * bubble is idle, and the island is either showing "Classifying..." with
     * a 40 s safety-net dismiss, or is dismissed (if text is empty).
     */
    private fun finaliseCapture(text: String) {
        Log.d(TAG, "finaliseCapture: '${text.take(60)}' (${text.length} chars)")
        isRecording = false
        resetBubbleVisuals()
        releaseSpeechRecognizer()
        releaseAudioFocus()

        if (text.isNotEmpty()) {
            showIsland("Classifying...", Color.parseColor("#7C3AED"), android.R.drawable.ic_popup_sync)
            // Safety-net: island auto-dismisses if BackgroundNoteService never responds.
            scheduleIslandDismiss(ISLAND_SAFETY_DISMISS_MS)
            broadcastCapture(text, SOURCE_VOICE)
            FlutterEngineHolder.channel?.invokeMethod("notifyRecordingStopped", null)
        } else {
            dismissIslandAndReset()
            FlutterEngineHolder.channel?.invokeMethod("notifyRecordingFailed", null)
        }
    }

    private fun stopVoiceCapture() {
        isRecording = false   // Reset immediately so no subsequent gesture is blocked.
        Log.d(TAG, "stopVoiceCapture (elapsed=${System.currentTimeMillis() - recordingStartTime}ms)")
        stopListeningCalled = true
        releaseAudioFocus()
        restartListenRunnable?.let { mainHandler.removeCallbacks(it) }
        restartListenRunnable = null
        isUserHolding = false
        try {
            speechRecognizer?.stopListening()
        } catch (e: Exception) {
            Log.w(TAG, "stopListening threw", e)
            // If stop itself fails, use last partial or dismiss.
            val fallback = lastPartialTranscript.trim()
            if (fallback.isNotEmpty()) finaliseCapture(fallback)
            else dismissIslandAndReset()
        }
    }

    private fun openMicrophonePermissionSettings() {
        try {
            val intent = Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:$packageName")
            ).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.w(TAG, "openMicrophonePermissionSettings failed", e)
        }
    }

    private fun restartRecognizer(listener: RecognitionListener) {
        restartListenRunnable?.let { mainHandler.removeCallbacks(it) }
        restartListenRunnable = Runnable {
            if (!isUserHolding || !isRecording || stopListeningCalled) return@Runnable
            val intent = lastRecognizerIntent ?: return@Runnable
            try {
                releaseSpeechRecognizer()
                speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
                speechRecognizer?.setRecognitionListener(listener)
                speechRecognizer?.startListening(intent)
            } catch (e: Exception) {
                Log.e(TAG, "restartRecognizer failed", e)
                dismissIslandAndReset()
            }
        }
        mainHandler.postDelayed(restartListenRunnable!!, 150)
    }

    private fun releaseSpeechRecognizer() {
        try { speechRecognizer?.cancel()  } catch (_: Exception) {}
        try { speechRecognizer?.destroy() } catch (_: Exception) {}
        speechRecognizer = null
    }

    // ─── Island UI ────────────────────────────────────────────────────────────

    /**
     * Shows or updates the floating top island pill.
     * Idempotent — safe to call repeatedly with new text.
     */
    private fun showIsland(text: String, bgColor: Int, iconRes: Int = 0) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            mainHandler.post { showIsland(text, bgColor, iconRes) }
            return
        }

        // Reuse existing view if already shown — just update text/colour.
        if (islandView != null && islandLabel != null && islandBg != null) {
            islandBaseColor = bgColor
            islandLabel?.text = text
            applyIslandAppearance(bgColor)
            islandView?.animate()
                ?.scaleX(1.025f)
                ?.scaleY(1.025f)
                ?.translationY(-dp(1f).toFloat())
                ?.setDuration(110)
                ?.withEndAction {
                    islandView?.animate()
                        ?.scaleX(1f)
                        ?.scaleY(1f)
                        ?.translationY(0f)
                        ?.setDuration(140)
                        ?.start()
                }
                ?.start()
            return
        }

        // Build the island from scratch.
        val screenW = displayWidth()
        val pillW   = (screenW * 0.75f).toInt().coerceAtLeast(dp(200f))

        islandBaseColor = bgColor
        val bg = buildIslandDrawable(bgColor, overlaySettings)
        islandBg = bg

        val pill = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            background  = bg
            elevation   = dp(12f).toFloat()
            gravity     = Gravity.CENTER_VERTICAL
            setPadding(dp(13f), dp(8f), dp(13f), dp(8f))
        }

        if (iconRes != 0) {
            val iconView = ImageView(this).apply {
                setImageResource(iconRes)
                setColorFilter(Color.WHITE)
                layoutParams = LinearLayout.LayoutParams(dp(15f), dp(15f)).apply {
                    rightMargin = dp(8f)
                }
            }
            pill.addView(iconView)
        }

        val label = TextView(this).apply {
            this.text      = text
            setTextColor(Color.parseColor("#F8FAFC"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12.5f)
            setTypeface(null, Typeface.BOLD)
            maxLines       = 1
            ellipsize      = TextUtils.TruncateAt.END
            setSingleLine(true)
        }
        islandLabel = label
        pill.addView(label)

        val params = WindowManager.LayoutParams(
            pillW, WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            y = statusBarHeight() + dp(4f)
        }

        try {
            islandView = pill
            windowManager.addView(pill, params)
            pill.alpha = 0f
            pill.scaleX = 0.94f
            pill.scaleY = 0.94f
            pill.translationY = dp(6f).toFloat()
            pill.animate()
                .alpha(1f)
                .scaleX(1f)
                .scaleY(1f)
                .translationY(0f)
                .setDuration(240)
                .setInterpolator(OvershootInterpolator(1.1f))
                .start()
        } catch (e: Exception) {
            Log.e(TAG, "showIsland: addView failed", e)
            islandView = null; islandLabel = null; islandBg = null
        }
    }

    /**
     * Full island + bubble + recognizer reset.
     * ALWAYS call this on any terminal path (error, empty transcript, cancel).
     */
    fun dismissIslandAndReset() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            mainHandler.post { dismissIslandAndReset() }
            return
        }
        Log.d(TAG, "dismissIslandAndReset")
        cancelIslandDismiss()
        animateDismissIsland()
        resetBubbleVisuals()
        isRecording         = false
        isUserHolding       = false
        isResettingAfterError = false
        stopListeningCalled = false
        lastPartialTranscript = ""
    }

    private fun animateDismissIsland() {
        val view = islandView ?: return
        view.animate().alpha(0f).setDuration(200).withEndAction {
            try { windowManager.removeView(view) } catch (_: Exception) {}
            islandView = null; islandLabel = null; islandBg = null
        }.start()
    }

    private fun startIdleBubblePulse() {
        val view = bubbleView ?: return
        if (idlePulseAnimator?.isRunning == true) return
        idlePulseAnimator = ObjectAnimator.ofPropertyValuesHolder(
            view,
            PropertyValuesHolder.ofFloat("scaleX", 1f, 1.04f),
            PropertyValuesHolder.ofFloat("scaleY", 1f, 1.04f),
        ).apply {
            duration = 2200
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.REVERSE
            interpolator = AccelerateDecelerateInterpolator()
            start()
        }
    }

    private fun stopIdleBubblePulse() {
        idlePulseAnimator?.cancel()
        idlePulseAnimator = null
    }

    /** Schedules auto-dismiss of island after [delayMs]. Previous schedule is cancelled. */
    private fun scheduleIslandDismiss(delayMs: Long) {
        cancelIslandDismiss()
        islandDismissRunnable = Runnable { dismissIslandAndReset() }
        mainHandler.postDelayed(islandDismissRunnable!!, delayMs)
    }

    private fun cancelIslandDismiss() {
        islandDismissRunnable?.let { mainHandler.removeCallbacks(it) }
        islandDismissRunnable = null
    }

    // ─── Island update API (called from Flutter / BackgroundNoteService) ──────

    fun handleIslandUpdate(state: String, message: String?) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            mainHandler.post { handleIslandUpdate(state, message) }
            return
        }
        when (state) {
            "recording"   -> showIsland(message ?: "Listening...", Color.parseColor("#6366F1"), android.R.drawable.ic_btn_speak_now)
            "processing"  -> { cancelIslandDismiss(); showIsland("Classifying…", Color.parseColor("#7C3AED"), android.R.drawable.ic_popup_sync) }
            "saved"       -> { /* handled by handleSavedNotification */ }
            "idle", "error" -> dismissIslandAndReset()
        }
    }

    fun handleSavedNotification(title: String, category: String, prefix: String, @Suppress("UNUSED_PARAMETER") collection: String) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            mainHandler.post { handleSavedNotification(title, category, prefix, collection) }
            return
        }
        cancelIslandDismiss()
        val prefixLabel = if (prefix.equals("sys", ignoreCase = true)) "sys" else "AI"
        val (color, label, iconRes) = when (category.lowercase()) {
            "tasks"     -> Triple(Color.parseColor("#3B82F6"), "$prefixLabel • Saved in Tasks", android.R.drawable.checkbox_on_background)
            "reminders" -> Triple(Color.parseColor("#F59E0B"), "$prefixLabel • Saved in Reminders", android.R.drawable.ic_lock_idle_alarm)
            "ideas"     -> Triple(Color.parseColor("#10B981"), "$prefixLabel • Saved in Ideas", android.R.drawable.ic_menu_edit)
            "follow-up","follow_up" -> Triple(Color.parseColor("#8B5CF6"), "$prefixLabel • Saved in Follow-up", android.R.drawable.ic_menu_revert)
            "journal"   -> Triple(Color.parseColor("#EC4899"), "$prefixLabel • Saved in Journal", android.R.drawable.ic_menu_agenda)
            else         -> Triple(Color.parseColor("#6B7280"), "$prefixLabel • Saved in General", android.R.drawable.ic_menu_info_details)
        }
        val display = if (title.isBlank()) label else "$label • ${title.take(40)}"
        showIsland(display, color, iconRes)
        scheduleIslandDismiss(2_800L)
    }

    fun handleApplySettings(settingsJson: String) {
        mainHandler.post {
            overlaySettings = OverlayAppearanceSettings.fromJson(settingsJson)
            applyBubbleAppearance()
            if (islandView != null && islandLabel != null && islandBg != null) {
                applyIslandAppearance(islandBaseColor)
            }
        }
    }

    // ─── Text input banner ────────────────────────────────────────────────────

    private fun showTextInputBanner() {
        if (bannerView != null) return
        val bannerParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply { gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL; y = dp(8f) }

        val bg = GradientDrawable().apply {
            cornerRadius = dp(20f).toFloat()
            colors = intArrayOf(Color.parseColor("#1E1B4B"), Color.parseColor("#312E81"))
            orientation = GradientDrawable.Orientation.TL_BR
            setStroke(dp(1f), Color.parseColor("#7C3AED"))
        }

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16f), dp(12f), dp(16f), dp(12f))
            background = bg; elevation = dp(16f).toFloat()
        }

        val header = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL; gravity = Gravity.CENTER_VERTICAL }
        val title  = TextView(this).apply {
            text = "Quick Note"; setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f); setTypeface(null, Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }
        val close = TextView(this).apply {
            text = "✕"; setTextColor(Color.parseColor("#94A3B8"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            setPadding(dp(8f), dp(4f), 0, dp(4f))
            setOnClickListener { dismissBanner() }
        }
        header.addView(title); header.addView(close)

        val input = EditText(this).apply {
            hint = "What's on your mind?"; setHintTextColor(Color.parseColor("#64748B"))
            setTextColor(Color.WHITE); setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            background = GradientDrawable().apply { cornerRadius = dp(12f).toFloat(); setColor(Color.parseColor("#1F2937")) }
            setPadding(dp(12f), dp(10f), dp(12f), dp(10f))
            inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
            maxLines = 4; imeOptions = EditorInfo.IME_ACTION_DONE
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(90f)).apply { topMargin = dp(10f) }
        }

        val sendBtn = TextView(this).apply {
            text = "Save Note"; setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f); setTypeface(null, Typeface.BOLD)
            background = GradientDrawable().apply { cornerRadius = dp(12f).toFloat(); setColor(Color.parseColor("#6366F1")) }
            setPadding(dp(16f), dp(10f), dp(16f), dp(10f))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { topMargin = dp(10f) }
            setOnClickListener {
                val text = input.text.toString().trim()
                if (text.isNotEmpty()) {
                    try {
                        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                        imm.hideSoftInputFromWindow(input.windowToken, 0)
                    } catch (_: Exception) {}
                    dismissBanner()
                    broadcastCapture(text, SOURCE_TEXT)
                } else {
                    dismissBanner()
                }
            }
        }

        layout.addView(header); layout.addView(input); layout.addView(sendBtn)

        try {
            bannerView = layout
            windowManager.addView(layout, bannerParams)
            layout.post {
                input.requestFocus()
                try {
                    val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.showSoftInput(input, InputMethodManager.SHOW_IMPLICIT)
                } catch (_: Exception) {}
            }
        } catch (e: Exception) {
            Log.e(TAG, "showTextInputBanner: addView failed", e)
            bannerView = null
        }
    }

    private fun dismissBanner() {
        mainHandler.post {
            val v = bannerView ?: return@post
            try {
                try {
                    val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.hideSoftInputFromWindow(v.windowToken, 0)
                } catch (_: Exception) {}
                windowManager.removeView(v)
            } catch (_: Exception) {}
            bannerView = null
        }
    }

    // ─── Broadcast ────────────────────────────────────────────────────────────

    private fun broadcastCapture(text: String, source: String) {
        // ISSUE-03 FIX: use LocalBroadcastManager so NoteInputReceiver (which
        // registers via LBM) actually receives this event.
        val intent = Intent(ACTION_NOTE_CAPTURED).apply {
            putExtra(EXTRA_TEXT,   text)
            putExtra(EXTRA_SOURCE, source)
        }
        androidx.localbroadcastmanager.content.LocalBroadcastManager
            .getInstance(this)
            .sendBroadcast(intent)

        // Direct channel delivery as a fast-path for foreground sessions.
        // NoteInputReceiver handles the engine-dead fallback.
        FlutterEngineHolder.channel?.invokeMethod(
            "captureNote",
            hashMapOf("text" to text, "source" to source)
        )
    }

    // ─── Audio focus ──────────────────────────────────────────────────────────

    private fun requestAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                .setAudioAttributes(AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build())
                .setAcceptsDelayedFocusGain(false)
                .build()
            audioFocusRequest = req
            audioManager?.requestAudioFocus(req)
        } else {
            @Suppress("DEPRECATION")
            audioManager?.requestAudioFocus(null, AudioManager.STREAM_VOICE_CALL, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
        }
    }

    private fun releaseAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
            audioFocusRequest = null
        } else {
            @Suppress("DEPRECATION")
            audioManager?.abandonAudioFocus(null)
        }
    }

    // ─── Bubble visual reset ──────────────────────────────────────────────────

    private fun resetBubbleVisuals() {
        pulseAnimator?.cancel(); pulseAnimator = null
        stopIdleBubblePulse()
        bubbleView?.scaleX = 1f; bubbleView?.scaleY = 1f
        applyBubbleAppearance()
        bubbleIcon?.setImageDrawable(ContextCompat.getDrawable(this, android.R.drawable.ic_btn_speak_now))
        bubbleIcon?.setColorFilter(Color.WHITE)
        startIdleBubblePulse()
    }

    private fun applyBubbleAppearance() {
        val view = bubbleView ?: return
        bubbleBackground = buildBubbleDrawable(overlaySettings)
        view.background = bubbleBackground
        view.alpha = overlaySettings.alpha.coerceIn(0.3f, 1f)
        bubbleGrowEnabled = overlaySettings.growEnabled
    }

    private fun applyIslandAppearance(baseColor: Int) {
        val view = islandView ?: return
        islandBg = buildIslandDrawable(baseColor, overlaySettings)
        view.background = islandBg
    }

    private fun buildBubbleDrawable(settings: OverlayAppearanceSettings): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            applyFill(this, settings, Color.parseColor("#6366F1"), true)
        }
    }

    private fun buildIslandDrawable(baseColor: Int, settings: OverlayAppearanceSettings): GradientDrawable {
        return GradientDrawable().apply {
            cornerRadius = dp(24f).toFloat()
            applyFill(this, settings, baseColor, false)
        }
    }

    private fun applyFill(
        drawable: GradientDrawable,
        settings: OverlayAppearanceSettings,
        baseColor: Int,
        isBubble: Boolean,
    ) {
        val alpha = settings.alpha.coerceIn(0.3f, 1f)
        when (settings.colorFill.lowercase(Locale.ROOT)) {
            "solid" -> {
                drawable.setColor(applyAlpha(settings.solidColor, alpha))
            }
            "lineargradient" -> {
                drawable.orientation = GradientDrawable.Orientation.TL_BR
                drawable.colors = intArrayOf(
                    applyAlpha(settings.gradientStart, alpha),
                    applyAlpha(settings.gradientEnd, alpha),
                )
            }
            "radialgradient" -> {
                drawable.gradientType = GradientDrawable.RADIAL_GRADIENT
                drawable.gradientRadius = if (isBubble) dp(64f).toFloat() else dp(96f).toFloat()
                drawable.colors = intArrayOf(
                    applyAlpha(settings.gradientStart, alpha),
                    applyAlpha(settings.gradientEnd, alpha),
                )
            }
            else -> {
                drawable.setColor(applyAlpha(baseColor, alpha))
            }
        }

        when (settings.borderStyle.lowercase(Locale.ROOT)) {
            "none" -> drawable.setStroke(0, Color.TRANSPARENT)
            "hairline" -> drawable.setStroke(
                dp(1f),
                applyAlpha(settings.borderColor, 0.5f),
            )
            else -> drawable.setStroke(
                if (isBubble) dp(1.5f) else dp(1f),
                applyAlpha(settings.borderColor, 0.88f),
            )
        }
    }

    private fun applyAlpha(color: Int, alpha: Float): Int {
        val clamped = alpha.coerceIn(0f, 1f)
        return Color.argb(
            (clamped * 255f).toInt(),
            Color.red(color),
            Color.green(color),
            Color.blue(color),
        )
    }

    // ─── Full reset ───────────────────────────────────────────────────────────

    /** Called on destroy to ensure zero leaks. */
    private fun performFullReset(removeViews: Boolean) {
        cancelIslandDismiss()
        longPressRunnable?.let    { mainHandler.removeCallbacks(it) }
        restartListenRunnable?.let{ mainHandler.removeCallbacks(it) }
        longPressRunnable    = null
        restartListenRunnable = null
        releaseAudioFocus()
        releaseSpeechRecognizer()
        isRecording = false; isUserHolding = false; isResettingAfterError = false
        if (removeViews) {
            try { bannerView?.let { windowManager.removeView(it) }  } catch (_: Exception) {}
            try { islandView?.let { windowManager.removeView(it) }  } catch (_: Exception) {}
            try { bubbleView?.let { windowManager.removeView(it) }  } catch (_: Exception) {}
            bannerView = null; islandView = null; bubbleView = null
        } else {
            animateDismissIsland()
            dismissBanner()
            resetBubbleVisuals()
        }
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private fun vibrate(ms: Long = 40) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                (getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                    .defaultVibrator.vibrate(VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                (getSystemService(VIBRATOR_SERVICE) as? Vibrator)
                    ?.vibrate(VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE))
            }
        } catch (_: Exception) {}
    }

    private fun recognizerErrorToString(code: Int) = when (code) {
        SpeechRecognizer.ERROR_AUDIO                  -> "AUDIO"
        SpeechRecognizer.ERROR_CLIENT                 -> "CLIENT"
        SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "NO_PERMISSION"
        SpeechRecognizer.ERROR_NETWORK                -> "NETWORK"
        SpeechRecognizer.ERROR_NETWORK_TIMEOUT        -> "NETWORK_TIMEOUT"
        SpeechRecognizer.ERROR_NO_MATCH               -> "NO_MATCH"
        SpeechRecognizer.ERROR_RECOGNIZER_BUSY        -> "BUSY"
        SpeechRecognizer.ERROR_SERVER                 -> "SERVER"
        SpeechRecognizer.ERROR_SPEECH_TIMEOUT         -> "SPEECH_TIMEOUT"
        else                                          -> "UNKNOWN($code)"
    }

    /**
     * Intelligently merges incremental STT packets.
     * Handles the common case where the recogniser emits overlapping hypotheses.
     */
    private fun mergeTranscript(existing: String, incoming: String): String {
        val prev = existing.replace(Regex("\\s+"), " ").trim()
        val next = incoming.replace(Regex("\\s+"), " ").trim()
        if (next.isEmpty()) return prev
        if (prev.isEmpty()) return next
        if (next.equals(prev, ignoreCase = true)) return prev
        if (next.startsWith(prev, ignoreCase = true)) return next
        if (prev.startsWith(next, ignoreCase = true))
            return if (next.length < prev.length * 0.65f) prev else next

        val maxOverlap = minOf(prev.length, next.length)
        for (len in maxOverlap downTo 2) {
            if (prev.takeLast(len).equals(next.take(len), ignoreCase = true))
                return (prev + next.drop(len)).replace(Regex("\\s+"), " ").trim()
        }
        val ratio = next.length.toFloat() / prev.length.toFloat().coerceAtLeast(1f)
        return if (ratio in 0.7f..1.4f) next else "$prev $next".replace(Regex("\\s+"), " ").trim()
    }
}