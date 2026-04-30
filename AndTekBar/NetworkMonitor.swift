import Network
import Foundation

final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "mn.frd.AndTekBar.NetworkMonitor")
    private var onUnavailable: (() -> Void)?

    func start(onUnavailable: @escaping () -> Void) {
        self.onUnavailable = onUnavailable
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status != .satisfied {
                DispatchQueue.main.async { self?.onUnavailable?() }
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }
}
