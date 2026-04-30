import XCTest
@testable import AndTekBar

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        // URLSession converts httpBody to httpBodyStream internally; drain it back.
        var req = request
        if req.httpBody == nil, let stream = req.httpBodyStream {
            stream.open()
            var body = Data()
            var buf = [UInt8](repeating: 0, count: 1024)
            while stream.hasBytesAvailable {
                let n = stream.read(&buf, maxLength: buf.count)
                if n > 0 { body.append(buf, count: n) }
            }
            stream.close()
            req.httpBody = body
        }
        do {
            let (response, data) = try handler(req)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class AndTekServiceTests: XCTestCase {
    var session: URLSession!

    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        session = nil
    }

    func testLoginPostsToCorrectURL() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        let service = AndTekService(
            server: "192.168.1.1", port: "8080",
            api: "andphone/ACDService", mac: "AABBCC112233",
            session: session
        )
        try await service.setState(.login)
        XCTAssertEqual(capturedRequest?.url?.absoluteString, "http://192.168.1.1:8080/andphone/ACDService")
        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
    }

    func testLoginBodyContainsStateZero() async throws {
        var capturedBody: String?
        MockURLProtocol.requestHandler = { request in
            capturedBody = request.httpBody.flatMap { String(data: $0, encoding: .utf8) }
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        let service = AndTekService(
            server: "192.168.1.1", port: "8080",
            api: "andphone/ACDService", mac: "AABBCC112233",
            session: session
        )
        try await service.setState(.login)
        XCTAssertTrue(capturedBody?.contains("state=0") == true, "body: \(capturedBody ?? "nil")")
        XCTAssertTrue(capturedBody?.contains("dev=SEPAABBCC112233") == true, "body: \(capturedBody ?? "nil")")
    }

    func testLogoutBodyContainsStateOne() async throws {
        var capturedBody: String?
        MockURLProtocol.requestHandler = { request in
            capturedBody = request.httpBody.flatMap { String(data: $0, encoding: .utf8) }
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        let service = AndTekService(
            server: "192.168.1.1", port: "8080",
            api: "andphone/ACDService", mac: "AABBCC112233",
            session: session
        )
        try await service.setState(.logout)
        XCTAssertTrue(capturedBody?.contains("state=1") == true, "body: \(capturedBody ?? "nil")")
    }

    func testThrowsOnNon200StatusCode() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        let service = AndTekService(
            server: "192.168.1.1", port: "8080",
            api: "andphone/ACDService", mac: "AABBCC112233",
            session: session
        )
        do {
            try await service.setState(.login)
            XCTFail("Expected error, got none")
        } catch {}
    }
}
