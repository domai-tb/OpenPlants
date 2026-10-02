import UIKit
import Flutter

private final class LocalTimezoneStreamHandler: NSObject, FlutterStreamHandler {
  private var observer: NSObjectProtocol?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    observer = NotificationCenter.default.addObserver(
      forName: .NSSystemTimeZoneDidChange,
      object: nil,
      queue: .main
    ) { _ in
      events(TimeZone.current.identifier)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let observer {
      NotificationCenter.default.removeObserver(observer)
      self.observer = nil
    }
    return nil
  }

  deinit {
    if let observer { NotificationCenter.default.removeObserver(observer) }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterMethodChannel(name: "openplants/local_timezone", binaryMessenger: controller.binaryMessenger)
        .setMethodCallHandler { call, result in
          if call.method == "getLocalTimezone" { result(TimeZone.current.identifier) }
          else { result(FlutterMethodNotImplemented) }
        }
      FlutterEventChannel(name: "openplants/timezone_changes", binaryMessenger: controller.binaryMessenger)
        .setStreamHandler(LocalTimezoneStreamHandler())
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
