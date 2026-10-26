package com.example.budget_buddy

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.SystemClock
import android.os.ParcelFileDescriptor
import android.graphics.pdf.PdfRenderer
import android.graphics.Bitmap
import java.io.File
import java.io.ByteArrayOutputStream
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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "budget_buddy/payment_document").setMethodCallHandler { call, result ->
            if (call.method != "renderPdfPage") {
                result.notImplemented()
            } else {
                val bytes = call.argument<ByteArray>("bytes")
                val index = call.argument<Int>("page") ?: 0
                if (bytes == null || bytes.isEmpty() || bytes.size > 5 * 1024 * 1024 || index < 0) {
                    result.error("invalid_document", "Invalid payment document", null)
                } else {
                    Thread {
                        var temporary: File? = null
                        try {
                            temporary = File.createTempFile("payment-preview-", ".pdf", cacheDir)
                            temporary.writeBytes(bytes)
                            val output = ParcelFileDescriptor.open(temporary, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
                                PdfRenderer(descriptor).use { renderer ->
                                    require(index < renderer.pageCount)
                                    renderer.openPage(index).use { page ->
                                        val scale = minOf(1024.0 / page.width, 4096.0 / page.height)
                                        val image = Bitmap.createBitmap(maxOf(1, (page.width * scale).toInt()),
                                            maxOf(1, (page.height * scale).toInt()), Bitmap.Config.ARGB_8888)
                                        try {
                                            image.eraseColor(android.graphics.Color.WHITE)
                                            page.render(image, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                                            val stream = ByteArrayOutputStream()
                                            check(image.compress(Bitmap.CompressFormat.PNG, 100, stream))
                                            mapOf("pages" to renderer.pageCount, "image" to stream.toByteArray())
                                        } finally { image.recycle() }
                                    }
                                }
                            }
                            runOnUiThread { result.success(output) }
                        } catch (_: Exception) {
                            runOnUiThread { result.error("unavailable_document", "This PDF could not be previewed", null) }
                        } finally { temporary?.delete() }
                    }.start()
                }
            }
        }
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
