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

        if #available(macOS 14, *) {
            OpenSettingsButton()
        } else {
            Button("Settings...") {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first(where: { $0.styleMask.contains(.titled) }) {
                    window.makeKeyAndOrderFront(nil)
                } else {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
            }
            .keyboardShortcut(",", modifiers: .command)
        }

        Divider()

        Button("Quit AndTekBar") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}

@available(macOS 14, *)
private struct OpenSettingsButton: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Button("Settings...") {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            if let window = NSApp.windows.first(where: { $0.styleMask.contains(.titled) }) {
                window.makeKeyAndOrderFront(nil)
            } else {
                openSettings()
            }
        }
        .keyboardShortcut(",", modifiers: .command)
    }
}
