import Foundation
import Network
import Combine

// MARK: - Network Monitor (singleton)
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected: Bool = true
    @Published private(set) var connectionType: ConnectionType = .unknown

    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue(label: "com.aleha.networkmonitor")

    enum ConnectionType {
        case wifi, cellular, ethernet, unknown
    }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected     = path.status == .satisfied
                self?.connectionType  = Self.type(from: path)
            }
        }
        monitor.start(queue: queue)
    }

    private static func type(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi)      { return .wifi }
        if path.usesInterfaceType(.cellular)  { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        return .unknown
    }

    deinit { monitor.cancel() }
}
