import XCTest
@testable import AndTekBar

final class AppStateTests: XCTestCase {
    func testInitialStateIsOffline() {
        XCTAssertEqual(AppState.shared.connectionState, .offline)
    }
}
