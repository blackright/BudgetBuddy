package com.example.budget_buddy

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.SystemClock
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/// Answers two channels:
///  - the monotonic-clock channel (research R3, FR-015): `SystemClock.elapsedRealtime()`
///  - the screen-lock event channel: streams "locked"/"unlocked" events from the
///    Android keyguard, so the Dart side can tell a real phone lock from a plain
///    app switch and re-lock immediately only in the former case (FR-022).
class MainActivity : FlutterFragmentActivity() {
    private var screenLockEventSink: EventChannel.EventSink? = null
    private val screenReceiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_SCREEN_OFF -> screenLockEventSink?.success("locked")
                Intent.ACTION_SCREEN_ON -> screenLockEventSink?.success("unlocked")
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CLOCK_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "elapsedRealtimeMs" -> result.success(SystemClock.elapsedRealtime())
                else -> result.notImplemented()
            }
        }
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_LOCK_EVENT_CHANNEL_NAME,
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                screenLockEventSink = events
                val filter = IntentFilter().apply {
                    addAction(Intent.ACTION_SCREEN_OFF)
                    addAction(Intent.ACTION_SCREEN_ON)
                }
                registerReceiver(screenReceiver, filter)
            }
            override fun onCancel(arguments: Any?) {
                try { unregisterReceiver(screenReceiver) } catch (_: Exception) {}
                screenLockEventSink = null
            }
        })
    }

    override fun onDestroy() {
        try { unregisterReceiver(screenReceiver) } catch (_: Exception) {}
        super.onDestroy()
    }

    private companion object {
        const val CLOCK_CHANNEL_NAME = "budget_buddy/monotonic_clock"
        const val SCREEN_LOCK_EVENT_CHANNEL_NAME = "budget_buddy/screen_lock_events"
    }
}
