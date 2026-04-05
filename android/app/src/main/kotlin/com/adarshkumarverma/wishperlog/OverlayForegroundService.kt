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
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.text.InputType
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

class OverlayForegroundService : Service() {

    companion object {
        private const val TAG = "OverlayForegroundSvc"
        const val ACTION_NOTE_CAPTURED = "com.wishperlog.NOTE_CAPTURED"
        const val EXTRA_TEXT = "extra_text"
        const val EXTRA_SOURCE = "extra_source"
        const val SOURCE_VOICE = "voice_overlay"
        const val SOURCE_TEXT = "text_overlay"

        @Volatile
        private var instance: java.lang.ref.WeakReference<OverlayForegroundService>? = null

        /** Called by MainActivity when Flutter pushes a CaptureUiController state change. */
        fun updateIsland(state: String, message: String?) {
            instance?.get()?.handleIslandUpdate(state, message)
        }

        /** Called by Flutter after a note has been saved — shows saved pill with category. */
        fun notifySaved(title: String, category: String) {
            instance?.get()?.handleSavedNotification(title, category)
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
    private val handler = Handler(Looper.getMainLooper())

    // Safety: track whether stopListening was called so we ignore spurious onResults
    private var stopListeningCalled = false

    // ─── Bubble views ───────────────────────────────────────────────────────────
    private var bubbleIcon: ImageView? = null
    private var bubbleBackground: GradientDrawable? = null

    override fun onBind(intent: Intent): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startForeground(1, createNotification())
        instance = java.lang.ref.WeakReference(this)
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
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

    private fun createBubble() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !android.provider.Settings.canDrawOverlays(this)) {
            stopSelf(); return
        }

        val prefs = getSharedPreferences("com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)

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
        val longPressDelayMs = 200L
        val doubleTapTimeoutMs = 280L
        var lastTapUpAt = 0L

        frame.setOnTouchListener { v, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    initX = bubbleParams.x; initY = bubbleParams.y
                    initTX = event.rawX; initTY = event.rawY
                    isDragging = false
                    longPressTriggered = false
                    longPressRunnable?.let { handler.removeCallbacks(it) }
                    longPressRunnable = Runnable {
                        longPressTriggered = true
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
                    longPressRunnable?.let { handler.removeCallbacks(it) }
                    val cx = bubbleParams.x + v.width / 2
                    if (isDragging) {
                        bubbleParams.x = if (cx > displayWidth() / 2) displayWidth() - dp(64f) else 0
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

                    if (longPressTriggered && isRecording) {
                        stopVoiceCapture()
                    }
                    longPressTriggered = false
                    true
                }
                MotionEvent.ACTION_CANCEL -> {
                    longPressRunnable?.let { handler.removeCallbacks(it) }
                    longPressTriggered = false
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

        if (isRecording) return

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            Log.w(TAG, "startVoiceCapture: RECORD_AUDIO missing, asking Flutter to request permission")
            FlutterEngineHolder.channel?.invokeMethod("promptMicrophonePermission", null)
            showPersistentIsland("Microphone permission required", Color.parseColor("#EF4444"))
            handler.postDelayed({ dismissIsland() }, 3000)
            return
        }

        Log.d(TAG, "startVoiceCapture: starting recognizer")
        isRecording = true
        stopListeningCalled = false

        // Tell Flutter the island should show recording state.
        FlutterEngineHolder.channel?.invokeMethod("notifyRecordingStarted", null)

        // Show "Listening..." on the native island immediately (works even when app is off-screen)
        showPersistentIsland("🎙 Listening...", Color.parseColor("#6366F1"))

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

        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            Log.e(TAG, "startVoiceCapture: speech recognition not available on device")
            isRecording = false
            resetBubble()
            dismissIsland()
            return
        }

        releaseSpeechRecognizer()
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        Log.d(TAG, "startVoiceCapture: SpeechRecognizer created")
        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onResults(results: Bundle?) {
                if (stopListeningCalled.not() && !isRecording) return // stale callback guard
                Log.d(TAG, "onResults: received final recognition results")
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                val text = matches?.firstOrNull()?.trim() ?: ""
                isRecording = false
                resetBubble()
                releaseSpeechRecognizer()
                if (text.isNotEmpty()) {
                    // Show "Classifying..." on the native island BEFORE forwarding to Flutter
                    // This ensures the user sees processing state even when app is off-screen
                    showPersistentIsland("⚙ Classifying...", Color.parseColor("#7C3AED"))
                    broadcastCapture(text, SOURCE_VOICE)
                    // Tell Flutter to update its island state too (no-op if app is off-screen)
                    FlutterEngineHolder.channel?.invokeMethod("notifyRecordingStopped", null)
                } else {
                    dismissIsland()
                    FlutterEngineHolder.channel?.invokeMethod("notifyRecordingFailed", null)
                }
            }

            override fun onError(error: Int) {
                Log.e(TAG, "onError: code=$error (${recognizerErrorToString(error)})")
                isRecording = false
                resetBubble()
                dismissIsland()
                FlutterEngineHolder.channel?.invokeMethod("notifyRecordingFailed", null)
                releaseSpeechRecognizer()
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
            }
            override fun onPartialResults(partialResults: Bundle?) {
                val partial = partialResults
                    ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    ?.firstOrNull()
                    ?.take(80)
                if (!partial.isNullOrEmpty()) {
                    // Update native island with live transcript
                    showPersistentIsland("🎙 $partial", Color.parseColor("#6366F1"))
                    FlutterEngineHolder.channel?.invokeMethod(
                        "notifyRecordingTranscript",
                        hashMapOf("text" to partial)
                    )
                }
            }
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        }
        Log.d(TAG, "startVoiceCapture: startListening invoked")
        speechRecognizer?.startListening(intent)
    }

    private fun stopVoiceCapture() {
        Log.d(TAG, "stopVoiceCapture: stopping current session")
        stopListeningCalled = true
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

    private fun resetBubble() {
        isRecording = false
        pulseAnimator?.cancel()
        bubbleView?.scaleX = 1f
        bubbleView?.scaleY = 1f
        pulseAnimator = null

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
                    showPersistentIsland("⚙ Classifying...", Color.parseColor("#7C3AED"))
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
        val (label, accent) = when (state) {
            "recording" -> Pair(
                "🎙 ${if (message.isNullOrEmpty()) "Listening..." else message.take(45)}",
                Color.parseColor("#6366F1")
            )
            "processing" -> Pair("⚙ Classifying...", Color.parseColor("#7C3AED"))
            "saved" -> Pair("✓ ${message?.take(45) ?: "Saved"}", Color.parseColor("#10B981"))
            else -> {
                dismissIsland()
                return
            }
        }

        showPersistentIsland(label, accent)
        if (state == "saved") {
            handler.postDelayed({ dismissIsland() }, 2600)
        }
    }

    /**
     * Called directly by Flutter after background save completes.
     * This is the key path that works even when the app is in background.
     */
    private fun handleSavedNotification(title: String, category: String) {
        handler.post {
            val categoryEmoji = when (category) {
                "tasks" -> "✓"
                "reminders" -> "🔔"
                "ideas" -> "💡"
                "followUp" -> "↩"
                "journal" -> "📓"
                else -> "📎"
            }
            val categoryLabel = when (category) {
                "tasks" -> "Task"
                "reminders" -> "Reminder"
                "ideas" -> "Idea"
                "followUp" -> "Follow-up"
                "journal" -> "Journal"
                else -> "Note"
            }
            val label = "$categoryEmoji $categoryLabel · ${title.take(32)}"
            showPersistentIsland(label, Color.parseColor("#10B981"))
            handler.postDelayed({ dismissIsland() }, 2800)
        }
    }

    private fun showPersistentIsland(message: String, accentColor: Int) {
        handler.post {
            val existingPill = islandView as? TextView
            if (existingPill != null) {
                existingPill.text = message
                (existingPill.background as? GradientDrawable)?.setStroke(dp(1f), accentColor)
                return@post
            }

            val islandParams = WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                overlayType(),
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                y = dp(4f)
            }

            val pill = TextView(this).apply {
                text = message
                setTextColor(Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
                setTypeface(null, Typeface.BOLD)
                setPadding(dp(16f), dp(8f), dp(16f), dp(8f))
                background = GradientDrawable().apply {
                    cornerRadius = dp(20f).toFloat()
                    setColor(Color.parseColor("#1E1B4B"))
                    setStroke(dp(1f), accentColor)
                }
                elevation = dp(12f).toFloat()
            }

            islandView = pill
            try {
                windowManager.addView(pill, islandParams)
            } catch (e: Exception) {
                Log.w(TAG, "showPersistentIsland: addView failed: $e")
            }
        }
    }

    private fun dismissIsland() {
        handler.post {
            islandView?.let {
                try { windowManager.removeView(it) } catch (_: Exception) {}
            }
            islandView = null
        }
    }

    // ─── Broadcast to Flutter ───────────────────────────────────────────────────

    private fun broadcastCapture(text: String, source: String) {
        val intent = Intent(ACTION_NOTE_CAPTURED).apply {
            putExtra(EXTRA_TEXT, text)
            putExtra(EXTRA_SOURCE, source)
        }
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
    }

    // ─── Lifecycle ──────────────────────────────────────────────────────────────

    override fun onDestroy() {
        releaseSpeechRecognizer()
        bubbleView?.let { try { windowManager.removeView(it) } catch (_: Exception) {} }
        dismissBanner()
        dismissIsland()
        instance = null
        super.onDestroy()
    }
}