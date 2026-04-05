package com.adarshkumarverma.wishperlog

import android.app.Application
import android.util.Log

/**
 * Application subclass that registers the NoteInputReceiver at the Application
 * level rather than the Activity level. This ensures the receiver stays alive
 * even when MainActivity is backgrounded or destroyed, allowing the overlay
 * service to forward captured notes to Flutter at any time.
 *
 * IMPORTANT: Add android:name=".WishperlogApplication" to <application> in AndroidManifest.xml
 */
class WishperlogApplication : Application() {

    private val noteReceiver = NoteInputReceiver()

    override fun onCreate() {
        super.onCreate()
        Log.d("WishperlogApp", "Application onCreate — registering NoteInputReceiver")
        NoteInputReceiver.register(this, noteReceiver)
    }

    override fun onTerminate() {
        NoteInputReceiver.unregister(this, noteReceiver)
        super.onTerminate()
    }
}