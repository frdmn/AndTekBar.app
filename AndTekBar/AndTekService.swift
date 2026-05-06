import Foundation

struct AndTekService {
    enum Action: String {
        case login = "0"
        case logout = "1"
    }

    let server: String
    let port: String
    let api: String
    let mac: String
    var session: URLSession = .shared

    private var baseURL: URL {
        get throws {
            guard let url = URL(string: "http://\(server):\(port)/\(api)") else {
                throw URLError(.badURL)
            }
            return url
        }
    }

    func send(_ action: Action) async throws {
        var components = URLComponents()
        components.queryItems = [
            .init(name: "queue",  value: "all"),
            .init(name: "setsec", value: "-1"),
            .init(name: "page",   value: "available"),
            .init(name: "state",  value: action.rawValue),
            .init(name: "dev",    value: "SEP\(mac)"),
        ]
        var request = URLRequest(url: try baseURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        try await expectOK(request)
    }

    func ping() async throws {
        var request = URLRequest(url: try baseURL, timeoutInterval: 5)
        request.httpMethod = "GET"
        try await expectOK(request)
    }

    private func expectOK(_ request: URLRequest) async throws {
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
