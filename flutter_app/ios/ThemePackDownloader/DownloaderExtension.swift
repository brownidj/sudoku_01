import BackgroundAssets
import ExtensionFoundation
import StoreKit

// Matches Xcode's Apple-Hosted, Managed Background Download template.
// Both pilot packs are on-demand; nothing blocks the game's first launch.
@main
struct DownloaderExtension: StoreDownloaderExtension {}
