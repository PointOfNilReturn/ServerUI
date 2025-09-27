import Foundation
import Network

enum ServerBootstrap {
    static func start(port rawValue: UInt16) throws {
        let port = NWEndpoint.Port(rawValue: rawValue)!
        let listener = try NWListener(using: .tcp, on: port)

        listener.newConnectionHandler = { connection in
            connection.start(queue: .main)
            Task.detached {
                await ConnectionHandler.handle(connection: connection)
            }
        }

        listener.start(queue: .main)
        print("➡️  Listening on http://127.0.0.1:\(port)")
    }
}
