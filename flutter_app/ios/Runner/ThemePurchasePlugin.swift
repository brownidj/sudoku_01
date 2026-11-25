import Flutter
import StoreKit

/// Separate from the Full Version unlock. StoreKit verifies every entitlement;
/// pending, cancelled, revoked and unverified transactions never unlock downloads.
final class ThemePurchasePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  private var updates: Task<Void, Never>?

  static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = ThemePurchasePlugin()
    let channel = FlutterMethodChannel(name: "org.topository.animalsudoku/theme_purchases",
      binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(plugin, channel: channel)
    FlutterEventChannel(name: "org.topository.animalsudoku/theme_purchases/updates",
      binaryMessenger: registrar.messenger()).setStreamHandler(plugin)
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    if #available(iOS 15.0, *) {
      updates = Task { @MainActor [weak self] in
        for await _ in Transaction.updates {
          // Recount current verified entitlements rather than trusting the event.
          self?.sink?(true)
        }
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    updates?.cancel()
    updates = nil
    sink = nil
    return nil
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    Task { @MainActor in
      guard #available(iOS 15.0, *) else {
        result(FlutterError(code: "unsupported", message: "Theme purchases require iOS 15 or later.", details: nil))
        return
      }
      let args = call.arguments as? [String: Any] ?? [:]
      let id = args["id"] as? String ?? ""
      do {
        switch call.method {
        case "products":
          let ids = args["ids"] as? [String] ?? []
          let products = try await Product.products(for: ids)
          result(products.filter { $0.type == .nonConsumable }.map { ["id": $0.id, "price": $0.displayPrice] })
        case "owns":
          var owned = false
          for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement,
               transaction.productID == id, transaction.productType == .nonConsumable,
               transaction.revocationDate == nil {
              owned = true
              // Persisted by StoreKit; the entitlement survives finishing.
              await transaction.finish()
            }
          }
          result(owned)
        case "purchase":
          guard let product = try await Product.products(for: [id]).first,
                product.type == .nonConsumable else {
            result(FlutterError(code: "unavailable", message: "This theme is not available for purchase yet.", details: nil))
            return
          }
          switch try await product.purchase() {
          case .success(let verification):
            guard case .verified(let transaction) = verification,
                  transaction.productID == id, transaction.revocationDate == nil else {
              result(FlutterError(code: "unverified", message: "The purchase could not be verified.", details: nil))
              return
            }
            await transaction.finish()
            result("purchased")
            self.sink?(true)
          case .pending: result("pending")
          case .userCancelled: result("cancelled")
          @unknown default: result("pending")
          }
        case "restore":
          try await AppStore.sync()
          result(nil)
          self.sink?(true)
        default: result(FlutterMethodNotImplemented)
        }
      } catch {
        result(FlutterError(code: "store_error", message: error.localizedDescription, details: nil))
      }
    }
  }
}
