import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appState = AppState.shared
    private var observers: [NSObjectProtocol] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { await appState.checkServer() }
        observeSession()
        observeWindows()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard appState.connectionState == .online else { return .terminateNow }
        Task {
            await appState.logout()
            NSApp.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    private func observeSession() {
        let workspace  = NSWorkspace.shared.notificationCenter
        let distributed = DistributedNotificationCenter.default()

        let onLogin:  (Notification) -> Void = { [appState] _ in Task { await appState.login() } }
        let onLogout: (Notification) -> Void = { [appState] _ in Task { await appState.logout() } }

        observers += [
            workspace.addObserver(forName: NSWorkspace.sessionDidBecomeActiveNotification,
                                  object: nil, queue: .main, using: onLogin),
            workspace.addObserver(forName: NSWorkspace.sessionDidResignActiveNotification,
                                  object: nil, queue: .main, using: onLogout),
            distributed.addObserver(forName: .init("com.apple.screenIsUnlocked"),
                                    object: nil, queue: .main, using: onLogin),
            distributed.addObserver(forName: .init("com.apple.screenIsLocked"),
                                    object: nil, queue: .main, using: onLogout),
        ]
    }

    private func observeWindows() {
        let center = NotificationCenter.default
        observers += [
            center.addObserver(forName: NSWindow.didBecomeKeyNotification,
                               object: nil, queue: .main) { note in
                guard let window = note.object as? NSWindow,
                      window.styleMask.contains(.titled) else { return }
                NSApp.setActivationPolicy(.regular)
            },
            center.addObserver(forName: NSWindow.willCloseNotification,
                               object: nil, queue: .main) { _ in
                DispatchQueue.main.async {
                    let hasTitled = NSApp.windows.contains {
                        $0.isVisible && $0.styleMask.contains(.titled)
                    }
                    if !hasTitled { NSApp.setActivationPolicy(.accessory) }
                }
            },
        ]
    }
}
