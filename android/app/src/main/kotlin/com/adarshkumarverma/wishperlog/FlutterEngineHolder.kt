package com.adarshkumarverma.wishperlog

import io.flutter.plugin.common.MethodChannel

/**
 * Singleton holder so the NoteInputReceiver can access the Flutter MethodChannel
 * even when MainActivity may not be in the foreground.
 */
object FlutterEngineHolder {
    var channel: MethodChannel? = null
}
