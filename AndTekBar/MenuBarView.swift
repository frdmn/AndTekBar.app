import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appState: AppState
    let onLogin: () -> Void
    let onLogout: () -> Void
    let onReconnect: () -> Void

    var body: some View {
        if appState.connectionState != .failure {
            Button("Login",  action: onLogin)
            Button("Logout", action: onLogout)
        } else {
            Text("Server unreachable")
            Button("Reconnect", action: onReconnect)
        }

        Divider()

        SettingsMenuButton()

        Divider()

        Button("Quit AndTekBar") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q", modifiers: .command)
    }
}

private struct SettingsMenuButton: View {
    var body: some View {
        if #available(macOS 14, *) {
            ModernSettingsButton()
        } else {
            Button("Settings...") {
                activateAndShow {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}

@available(macOS 14, *)
private struct ModernSettingsButton: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Button("Settings...") {
            activateAndShow { openSettings() }
        }
        .keyboardShortcut(",", modifiers: .command)
    }
}

private func activateAndShow(orFallback fallback: () -> Void) {
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
    if let window = NSApp.windows.first(where: { $0.styleMask.contains(.titled) }) {
        window.makeKeyAndOrderFront(nil)
    } else {
        fallback()
    }
}
