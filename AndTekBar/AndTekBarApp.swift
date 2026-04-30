import SwiftUI

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
            Image(appState.connectionState.iconName)
                .renderingMode(.template)
        }

        Settings {
            SettingsView()
        }
    }
}

private extension ConnectionState {
    var iconName: String {
        switch self {
        case .online:  return "online"
        case .offline: return "offline"
        case .failure: return "failure"
        }
    }
}
