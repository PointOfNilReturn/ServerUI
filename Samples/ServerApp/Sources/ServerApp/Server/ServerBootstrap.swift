import Foundation
import Network
import Logging

enum ServerBootstrap {
    private static let logger = Logger(label: "com.serverui.server")
    
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
        logger.info("Server started", metadata: ["port": "\(rawValue)", "url": "http://127.0.0.1:\(rawValue)"])
    }
}
