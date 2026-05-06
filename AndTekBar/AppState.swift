import Foundation
import Network

enum ConnectionState: Equatable {
    case online, offline, failure
}

enum Defaults {
    static let server = "192.168.100.238"
    static let port   = "8080"
    static let api    = "andphone/ACDService"
    static let mac    = "002414B2XXXX"

    enum Key {
        static let server = "server"
        static let port   = "port"
        static let api    = "api"
        static let mac    = "mac"
    }
}

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published private(set) var connectionState: ConnectionState = .offline

    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "mn.frd.AndTekBar.NetworkMonitor")

    private init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard path.status != .satisfied else { return }
            Task { @MainActor in self?.connectionState = .failure }
        }
        pathMonitor.start(queue: monitorQueue)
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
            server: defaults.string(forKey: Defaults.Key.server) ?? Defaults.server,
            port:   defaults.string(forKey: Defaults.Key.port)   ?? Defaults.port,
            api:    defaults.string(forKey: Defaults.Key.api)    ?? Defaults.api,
            mac:    defaults.string(forKey: Defaults.Key.mac)    ?? Defaults.mac
        )
    }
}
