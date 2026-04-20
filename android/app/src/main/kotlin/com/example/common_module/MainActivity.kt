package com.calidig.mybuddy

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
  private val channelName = "core/screen_protection"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "enable" -> {
            App.setSecureEnabled(true)
            // Also apply immediately for the current activity.
            window.addFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
            result.success(null)
          }
          "disable" -> {
            App.setSecureEnabled(false)
            window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }
}
