package com.adarshkumarverma.wishperlog

import io.flutter.FlutterInjector
import io.flutter.app.FlutterApplication

class WishperlogApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        // Pre-warm the Flutter loader so BackgroundNoteService starts faster.
        FlutterInjector.instance().flutterLoader().startInitialization(this)
    }
}