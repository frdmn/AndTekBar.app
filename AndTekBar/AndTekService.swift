import Foundation

enum AndTekState {
    case login, logout

    var rawValue: String {
        switch self {
        case .login:  return "0"
        case .logout: return "1"
        }
    }
}

struct AndTekService {
    let server: String
    let port: String
    let api: String
    let mac: String
    var session: URLSession = .shared

    private func makeBaseURL() throws -> URL {
        guard let url = URL(string: "http://\(server):\(port)/\(api)") else {
            throw URLError(.badURL)
        }
        return url
    }

    func setState(_ state: AndTekState) async throws {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "queue",  value: "all"),
            URLQueryItem(name: "setsec", value: "-1"),
            URLQueryItem(name: "page",   value: "available"),
            URLQueryItem(name: "state",  value: state.rawValue),
            URLQueryItem(name: "dev",    value: "SEP\(mac)"),
        ]
        var request = URLRequest(url: try makeBaseURL())
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    func checkReachability() async throws {
        var request = URLRequest(url: try makeBaseURL(), timeoutInterval: 5)
        request.httpMethod = "GET"
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
