import Foundation
import Network

enum ConnectionHandler {
    static func handle(connection: NWConnection) async {
        // 1) Read until HTTP headers end (\r\n\r\n)
        var buffer = Data()
        while true {
            let chunk: Data? = await withCheckedContinuation { continuation in
                connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { data, _, isComplete, _ in
                    if let data {
                        continuation.resume(returning: data)
                    } else if isComplete {
                        continuation.resume(returning: nil)
                    } else {
                        continuation.resume(returning: Data())
                    }
                }
            }
            guard let chunk else { break }
            buffer.append(chunk)
            if buffer.range(of: Data("\r\n\r\n".utf8)) != nil { break }
        }

        let raw = String(data: buffer, encoding: .utf8) ?? ""
        let (method, path) = HTTP.parseRequestLine(from: raw) ?? ("", "")

        // 2) Route
        let response = Router.respond(method: method, path: path)

        // 3) Send and close
        await withCheckedContinuation { continuation in
            connection.send(content: response, completion: .contentProcessed { _ in continuation.resume() })
        }
        connection.cancel()
    }
}
