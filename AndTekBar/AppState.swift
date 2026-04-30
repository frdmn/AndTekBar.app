import Foundation

enum ConnectionState: Equatable {
    case online, offline, failure
}

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published private(set) var connectionState: ConnectionState = .offline

    private let networkMonitor = NetworkMonitor()

    private init() {
        networkMonitor.start { [weak self] in
            DispatchQueue.main.async { self?.connectionState = .failure }
        }
    }

    @MainActor
    func login() async {
        do {
            try await makeService().setState(.login)
            connectionState = .online
        } catch {
            connectionState = .failure
        }
    }

    @MainActor
    func logout() async {
        do {
            try await makeService().setState(.logout)
            connectionState = .offline
        } catch {
            connectionState = .failure
        }
    }

    @MainActor
    func checkServer() async {
        do {
            try await makeService().checkReachability()
            await login()
        } catch {
            connectionState = .failure
        }
    }

    private func makeService() -> AndTekService {
        AndTekService(
            server: UserDefaults.standard.string(forKey: "server") ?? "192.168.100.238",
            port:   UserDefaults.standard.string(forKey: "port")   ?? "8080",
            api:    UserDefaults.standard.string(forKey: "api")     ?? "andphone/ACDService",
            mac:    UserDefaults.standard.string(forKey: "mac")     ?? "002414B2XXXX"
        )
    }
}
