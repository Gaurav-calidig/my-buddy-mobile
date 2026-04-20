package com.calidig.mybuddy

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.view.WindowManager

class App : Application(), Application.ActivityLifecycleCallbacks {
  companion object {
    @Volatile
    private var secureEnabled: Boolean = false

    fun setSecureEnabled(enabled: Boolean) {
      secureEnabled = enabled
    }

    fun isSecureEnabled(): Boolean = secureEnabled

    private fun applySecureFlag(activity: Activity) {
      if (secureEnabled) {
        activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
      } else {
        activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
      }
    }
  }

  override fun onCreate() {
    super.onCreate()
    registerActivityLifecycleCallbacks(this)
  }

  override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
    applySecureFlag(activity)
  }

  override fun onActivityResumed(activity: Activity) {
    applySecureFlag(activity)
  }

  override fun onActivityStarted(activity: Activity) {}
  override fun onActivityPaused(activity: Activity) {}
  override fun onActivityStopped(activity: Activity) {}
  override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
  override fun onActivityDestroyed(activity: Activity) {}
}
