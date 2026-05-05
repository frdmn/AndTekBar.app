import SwiftUI
import AppKit

@main
struct AndTekBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                onLogin:     { Task { await appState.login() } },
                onLogout:    { Task { await appState.logout() } },
                onReconnect: { Task { await appState.checkServer() } }
            )
            .environmentObject(appState)
        } label: {
            Image(nsImage: appState.connectionState.menuBarImage)
        }

        Settings {
            SettingsView()
        }
    }
}

private extension ConnectionState {
    var iconOpacity: CGFloat {
        switch self {
        case .online:            return 1.0
        case .offline, .failure: return 0.5
        }
    }

    var baseNSImage: NSImage {
        switch self {
        case .online:
            return NSImage(systemSymbolName: "phone.circle.fill", accessibilityDescription: nil) ?? NSImage()
        case .offline:
            return NSImage(systemSymbolName: "phone.circle", accessibilityDescription: nil) ?? NSImage()
        case .failure:
            return NSImage(named: "custom.phone.circle.trianglebadge.exclamationmark") ?? NSImage()
        }
    }

    var iconScale: CGFloat { 1.1 }

    var menuBarImage: NSImage {
        let base = baseNSImage
        guard base.size.width > 0, base.size.height > 0 else {
            base.isTemplate = true
            return base
        }
        let scaledSize = NSSize(
            width: base.size.width * iconScale,
            height: base.size.height * iconScale
        )
        let rendered = NSImage(size: scaledSize, flipped: false) { rect in
            base.draw(in: rect, from: .zero, operation: .sourceOver, fraction: self.iconOpacity)
            return true
        }
        rendered.isTemplate = true
        return rendered
    }
}
