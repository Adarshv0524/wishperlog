package com.adarshkumarverma.wishperlog

import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.ViewConfiguration
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val longPressHandler = Handler(Looper.getMainLooper())
	private var isVolumeDownPressed = false
	private var longPressTriggered = false

	private val longPressRunnable = Runnable {
		if (isVolumeDownPressed && !longPressTriggered) {
			longPressTriggered = true
			sendVolumeLongPressBroadcast(phase = "start")
		}
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		val channel = MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"wishperlog/hardware",
		)

		HardwareMethodChannelHolder.channel = channel
		channel.setMethodCallHandler { _, result ->
			result.notImplemented()
		}
	}

	override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
		if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN && event?.repeatCount == 0) {
			isVolumeDownPressed = true
			longPressTriggered = false
			longPressHandler.postDelayed(
				longPressRunnable,
				ViewConfiguration.getLongPressTimeout().toLong(),
			)
			return true
		}
		return super.onKeyDown(keyCode, event)
	}

	override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
		if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
			longPressHandler.removeCallbacks(longPressRunnable)
			val hadLongPress = longPressTriggered

			isVolumeDownPressed = false
			longPressTriggered = false

			if (hadLongPress) {
				sendVolumeLongPressBroadcast(phase = "end")
				return true
			}
		}
		return super.onKeyUp(keyCode, event)
	}

	private fun sendVolumeLongPressBroadcast(phase: String) {
		val intent = Intent(
			VolumeDownLongPressReceiver.ACTION_VOLUME_DOWN_LONG_PRESS,
		).apply {
			setPackage(packageName)
			putExtra(VolumeDownLongPressReceiver.EXTRA_PHASE, phase)
		}
		sendBroadcast(intent)
	}
}
