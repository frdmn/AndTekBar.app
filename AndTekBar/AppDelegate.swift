import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appState = AppState.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { await appState.checkServer() }
        registerSystemEventObservers()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard appState.connectionState == .online else { return .terminateNow }
        Task {
            await appState.logout()
            NSApp.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    private func registerSystemEventObservers() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(handleLogin),
            name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)

        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(handleLogout),
            name: NSWorkspace.sessionDidResignActiveNotification, object: nil)

        DistributedNotificationCenter.default().addObserver(
            self, selector: #selector(handleLogout),
            name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)

        DistributedNotificationCenter.default().addObserver(
            self, selector: #selector(handleLogin),
            name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
    }

    @objc private func handleLogin(_ notification: Notification) {
        Task { await appState.login() }
    }

    @objc private func handleLogout(_ notification: Notification) {
        Task { await appState.logout() }
    }
}
