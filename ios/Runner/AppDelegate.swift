import Flutter
import UIKit
import workmanager_apple
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  private func getEnvVar(_ key: String) -> String? {
    guard let path = Bundle.main.path(forResource: "flutter_assets/.env", ofType: nil) else {
        return nil
    }
    do {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("\(key)=") {
                let parts = trimmed.components(separatedBy: "=")
                if parts.count >= 2 {
                    let value = parts[1...].joined(separator: "=")
                    return value.trimmingCharacters(in: .whitespaces)
                                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                                .trimmingCharacters(in: CharacterSet(charactersIn: "'"))
                }
            }
        }
    } catch {
        return nil
    }
    return nil
  }

  private func currentFlutterViewController() -> FlutterViewController? {
    // iOS apps using UIScene may not have `window` populated in AppDelegate.
    // Iterate through all foreground scenes to find the active FlutterViewController.
    let scenes = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
    for windowScene in scenes {
      for window in windowScene.windows {
        if let controller = window.rootViewController as? FlutterViewController {
          return controller
        }
      }
    }
    return nil
  }

  @objc private func handleUserDidTakeScreenshot(_ notification: Notification) {
    guard let flutterVC = currentFlutterViewController() else { return }
    let channel = FlutterMethodChannel(
      name: "core/screenshot_attempt",
      binaryMessenger: flutterVC.binaryMessenger
    )
    // Flutter side listens for `call.method == 'onScreenshot'`.
    channel.invokeMethod("onScreenshot", arguments: nil)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = getEnvVar("GOOGLE_MAPS_API_KEY") {
        GMSServices.provideAPIKey(apiKey)
    }
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "ios_sync_task")
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "ios_cleanup_task")
    GeneratedPluginRegistrant.register(with: self)
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "com.example.commonModule.backgroundLocationTask",
      frequency: NSNumber(value: 15 * 60)
    )

    // Emit an event to Flutter when the user takes a screenshot.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleUserDidTakeScreenshot(_:)),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
