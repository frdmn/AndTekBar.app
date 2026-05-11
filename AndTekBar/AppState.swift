import Foundation
import Network

enum ConnectionState: Equatable {
    case online, offline, failure
}

enum Defaults {
    static let endpoint = "http://192.168.100.238:8080/andphone/ACDService"
    static let mac      = "002414B2XXXX"

    enum Key {
        static let endpoint = "endpoint"
        static let mac      = "mac"
    }
}

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published private(set) var connectionState: ConnectionState = .offline

    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "mn.frd.AndTekBar.NetworkMonitor")

    private init() {
        Self.migrateIfNeeded()
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard path.status != .satisfied else { return }
            Task { @MainActor in self?.connectionState = .failure }
        }
        pathMonitor.start(queue: monitorQueue)
    }

    private static func migrateIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.string(forKey: Defaults.Key.endpoint) == nil,
              let server = defaults.string(forKey: "server"),
              let port   = defaults.string(forKey: "port"),
              let api    = defaults.string(forKey: "api")
        else { return }
        defaults.set("http://\(server):\(port)/\(api)", forKey: Defaults.Key.endpoint)
        defaults.removeObject(forKey: "server")
        defaults.removeObject(forKey: "port")
        defaults.removeObject(forKey: "api")
    }

    @MainActor
    func login() async {
        await update(to: .online, action: .login)
    }

    @MainActor
    func logout() async {
        await update(to: .offline, action: .logout)
    }

    @MainActor
    func checkServer() async {
        do {
            try await service.ping()
            await login()
        } catch {
            connectionState = .failure
        }
    }

    @MainActor
    private func update(to newState: ConnectionState, action: AndTekService.Action) async {
        do {
            try await service.send(action)
            connectionState = newState
        } catch {
            connectionState = .failure
        }
    }

    private var service: AndTekService {
        let defaults = UserDefaults.standard
        return AndTekService(
            endpoint: defaults.string(forKey: Defaults.Key.endpoint) ?? Defaults.endpoint,
            mac:      defaults.string(forKey: Defaults.Key.mac)      ?? Defaults.mac
        )
    }
}
