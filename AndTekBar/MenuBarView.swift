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
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
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
            openSettings()
            NSApp.activate(ignoringOtherApps: true)
        }
        .keyboardShortcut(",", modifiers: .command)
    }
}
