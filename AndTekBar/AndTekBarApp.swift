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
        self == .online ? 1.0 : 0.5
    }

    var baseImage: NSImage {
        let config = NSImage.SymbolConfiguration(scale: .medium)
        switch self {
        case .online:
            return NSImage(systemSymbolName: "phone.circle.fill", accessibilityDescription: nil)?
                .withSymbolConfiguration(config) ?? NSImage()
        case .offline:
            return NSImage(systemSymbolName: "phone.circle", accessibilityDescription: nil)?
                .withSymbolConfiguration(config) ?? NSImage()
        case .failure:
            return NSImage(named: "custom.phone.circle.trianglebadge.exclamationmark") ?? NSImage()
        }
    }

    var menuBarImage: NSImage {
        let base = baseImage
        guard base.size.width > 0, base.size.height > 0 else {
            base.isTemplate = true
            return base
        }
        let scaled = NSSize(width: base.size.width * 1.1, height: base.size.height * 1.1)
        let opacity = iconOpacity
        let rendered = NSImage(size: scaled, flipped: false) { rect in
            base.draw(in: rect, from: .zero, operation: .sourceOver, fraction: opacity)
            return true
        }
        rendered.isTemplate = true
        return rendered
    }
}
