package com.domai_tb.openplants

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    private var timezoneEventSink: EventChannel.EventSink? = null
    private var timezoneReceiverRegistered = false
    private val timezoneReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            timezoneEventSink?.success(TimeZone.getDefault().id)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "openplants/local_timezone")
            .setMethodCallHandler { call, result ->
                if (call.method == "getLocalTimezone") result.success(TimeZone.getDefault().id)
                else result.notImplemented()
            }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "openplants/timezone_changes")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    timezoneEventSink = events
                    if (!timezoneReceiverRegistered) {
                        val filter = IntentFilter(Intent.ACTION_TIMEZONE_CHANGED)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            registerReceiver(timezoneReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
                        } else {
                            registerReceiver(timezoneReceiver, filter)
                        }
                        timezoneReceiverRegistered = true
                    }
                }

                override fun onCancel(arguments: Any?) {
                    unregisterTimezoneReceiver()
                }
            })
    }

    override fun onDestroy() {
        unregisterTimezoneReceiver()
        super.onDestroy()
    }

    private fun unregisterTimezoneReceiver() {
        timezoneEventSink = null
        if (timezoneReceiverRegistered) {
            unregisterReceiver(timezoneReceiver)
            timezoneReceiverRegistered = false
        }
    }
}
