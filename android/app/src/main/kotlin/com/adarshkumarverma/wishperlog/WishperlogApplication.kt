package com.adarshkumarverma.wishperlog

import android.app.Application
class WishperlogApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Receiver is registered by OverlayForegroundService directly.
    }
}