import BackgroundAssets
import Flutter
import Foundation
import System

/// No downloads or group access occur during registration. Configuration is
/// queried explicitly; Step 3 supplies the shared App Group and host BA keys.
final class AppleThemePackPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var implementation: AnyObject?

  static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = AppleThemePackPlugin()
    let methods = FlutterMethodChannel(
      name: "org.topository.animalsudoku/apple_theme_packs",
      binaryMessenger: registrar.messenger()
    )
    let events = FlutterEventChannel(
      name: "org.topository.animalsudoku/apple_theme_packs/progress",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(plugin, channel: methods)
    events.setStreamHandler(plugin)
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError? {
    eventSink = events
    return nil
  }

  // Stop UI observation without stopping an intentional background download.
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    Task { @MainActor in
      guard #available(iOS 26.0, *) else {
        if call.method == "getConfiguration" {
          result(["supported": false, "configured": false])
        } else {
          result(FlutterError(code: "unsupported", message: "Apple theme delivery requires iOS 26 or later.", details: nil))
        }
        return
      }
      let worker: AppleThemePackWorker
      if let existing = self.implementation as? AppleThemePackWorker {
        worker = existing
      } else {
        worker = AppleThemePackWorker { [weak self] event in self?.eventSink?(event) }
        self.implementation = worker
      }
      worker.handle(call, result: result)
    }
  }
}

@available(iOS 26.0, *)
@MainActor
private final class AppleThemePackWorker {
  private let emit: ([String: Any]) -> Void
  private var jobs: [String: Task<Void, Never>] = [:]
  private var progress: [String: Progress] = [:]
  private var cancelled: Set<String> = []

  init(emit: @escaping ([String: Any]) -> Void) { self.emit = emit }

  private var configuration: [String: Any] {
    let info = Bundle.main.infoDictionary ?? [:]
    let group = info["BAAppGroupID"] as? String ?? ""
    let flags = info["BAHasManagedAssetPacks"] as? Bool == true
      && info["BAUsesAppleHosting"] as? Bool == true
    let entitled = group.hasPrefix("group.")
      && FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) != nil
    return ["supported": true, "configured": flags && entitled]
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getConfiguration" {
      result(configuration)
      return
    }
    guard configuration["configured"] as? Bool == true else {
      result(FlutterError(code: "not_configured", message: "Configure Apple hosting and the shared App Group in step 3.", details: nil))
      return
    }
    if call.method == "listAssetPacks" {
      Task { @MainActor in
        do {
          let manager = AssetPackManager.shared
          let packs: Set<AssetPack>
          if #available(iOS 27.0, *) {
            packs = try await manager.manifest.assetPacks
          } else {
            packs = try await manager.allAssetPacks
          }
          result(packs.sorted { $0.id < $1.id }.map {
            ["id": $0.id, "version": $0.version, "downloadBytes": $0.downloadSize] as [String: Any]
          })
        } catch { result(Self.flutterError(error)) }
      }
      return
    }
    let args = call.arguments as? [String: Any] ?? [:]
    guard let id = args["assetPackId"] as? String,
          id.range(of: "^[a-z][a-z0-9_-]{2,63}$", options: .regularExpression) != nil else {
      result(FlutterError(code: "invalid_arguments", message: "Invalid asset-pack ID.", details: nil))
      return
    }
    switch call.method {
    case "ensureAvailable", "localPath":
      guard let path = args["relativePath"] as? String, Self.isSafePath(path) else {
        result(FlutterError(code: "invalid_arguments", message: "Invalid relative asset path.", details: nil))
        return
      }
      if call.method == "localPath" {
        do { result(try Self.localPath(path, packID: id)) }
        catch { result(Self.flutterError(error)) }
      } else {
        download(id: id, path: path, result: result)
      }
    case "cancelDownload":
      if let job = jobs[id] {
        cancelled.insert(id)
        progress[id]?.cancel()
        job.cancel()
      }
      result(nil)
    case "removeAssetPack":
      guard jobs[id] == nil else {
        result(FlutterError(code: "busy", message: "Cancel or finish the active download before removing its delivery copy.", details: nil))
        return
      }
      Task { @MainActor in
        do {
          try await AssetPackManager.shared.remove(assetPackWithID: id)
          result(nil)
        } catch { result(Self.flutterError(error)) }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func download(id: String, path: String, result: @escaping FlutterResult) {
    guard jobs[id] == nil else {
      result(FlutterError(code: "busy", message: "This pack is already downloading.", details: nil))
      return
    }
    cancelled.remove(id)
    jobs[id] = Task { @MainActor in
      let manager = AssetPackManager.shared
      let updates = manager.statusUpdates(forAssetPackWithID: id)
      let monitor = Task { @MainActor in
        for await update in updates {
          if Task.isCancelled { break }
          switch update {
          case .began:
            self.send(id, stage: "waiting")
          case .paused:
            self.send(id, stage: "paused")
          case .downloading(_, let value):
            self.progress[id] = value
            if self.cancelled.contains(id) { value.cancel() }
            self.send(id, stage: "downloading", value: value)
          case .finished:
            // Completion belongs to ensureLocalAvailability + path resolution.
            break
          case .failed:
            // Report the error once, from the request's completion below.
            break
          @unknown default:
            break
          }
        }
      }
      defer {
        monitor.cancel()
        self.jobs.removeValue(forKey: id)
        self.progress.removeValue(forKey: id)
        self.cancelled.remove(id)
      }
      do {
        self.send(id, stage: "waiting")
        // Refresh native versions before resolving cached catalogue/pack data.
        _ = try await manager.checkForUpdates()
        let pack: AssetPack
        if #available(iOS 27.0, *) {
          let manifest = try await manager.manifest
          guard let found = manifest.assetPack(withID: id) else {
            throw ManagedBackgroundAssetsError.assetPackNotFound(withID: id)
          }
          pack = found
        } else {
          pack = try await manager.assetPack(withID: id)
        }
        try Task.checkCancellation()
        if #available(iOS 26.4, *) {
          try await manager.ensureLocalAvailability(of: pack, requireLatestVersion: true)
        } else {
          try await manager.ensureLocalAvailability(of: pack)
        }
        try Task.checkCancellation()
        let local = try Self.localPath(path, packID: id)
        self.send(id, stage: "available")
        result(local)
      } catch {
        let wasCancelled = self.cancelled.contains(id) || error is CancellationError
        self.send(id, stage: wasCancelled ? "cancelled" : "failed")
        result(wasCancelled
          ? FlutterError(code: "cancelled", message: "Asset download cancelled.", details: nil)
          : Self.flutterError(error))
      }
    }
  }

  private func send(_ id: String, stage: String, value: Progress? = nil) {
    emit([
      "assetPackId": id, "stage": stage,
      "bytesReceived": value?.completedUnitCount ?? 0,
      "totalBytes": value?.totalUnitCount ?? 0,
    ])
  }

  private static func localPath(_ path: String, packID: String) throws -> String {
    // Verify membership before using the merged native asset namespace.
    let descriptor = try AssetPackManager.shared.descriptor(
      for: FilePath(path), searchingInAssetPackWithID: packID
    )
    try descriptor.close()
    return try AssetPackManager.shared.url(for: FilePath(path)).path
  }

  private static func isSafePath(_ path: String) -> Bool {
    let parts = path.split(separator: "/", omittingEmptySubsequences: false)
    return !parts.isEmpty && !path.contains("\\") && !path.contains(":")
      && parts.allSatisfy { !$0.isEmpty && $0 != "." && $0 != ".." }
  }

  private static func flutterError(_ error: Error) -> FlutterError {
    // Keep the NSError chain: localizedDescription alone hides which Apple
    // service failed (and makes runtime failures look like app setup errors).
    var errors: [[String: Any]] = []
    var current: NSError? = error as NSError
    while let native = current, errors.count < 8 {
      errors.append([
        "domain": native.domain,
        "code": native.code,
        "message": native.localizedDescription,
      ])
      current = native.userInfo[NSUnderlyingErrorKey] as? NSError
    }
    var message = error.localizedDescription
    #if targetEnvironment(simulator)
    let helperFailure = errors.contains {
      ($0["domain"] as? String == NSCocoaErrorDomain
        && [4097, 4099].contains($0["code"] as? Int ?? 0))
        || ($0["message"] as? String ?? "").localizedCaseInsensitiveContains("helper application")
    }
    if helperFailure {
      message += " Simulator's Apple Background Assets helper failed. "
        + "Check the simulator log for a missing system service such as "
        + "com.apple.spaceattributiond. If missing, test on a physical iPhone "
        + "or another simulator runtime. Check setup only verifies App Group "
        + "configuration; it does not verify Apple's system services."
    }
    #endif
    return FlutterError(code: "apple_asset_error", message: message, details: ["errors": errors])
  }
}
