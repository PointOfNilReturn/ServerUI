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
        let headers = HTTP.parseHeaders(from: raw)
        
        // 2) Read body if Content-Length is present (for POST requests)
        var body: Data? = nil
        if let contentLength = headers["Content-Length"], let length = Int(contentLength), length > 0 {
            var bodyBuffer = Data()
            
            // Check if we already have some body data after the headers
            if let headerEnd = buffer.range(of: Data("\r\n\r\n".utf8)) {
                let bodyStart = headerEnd.upperBound
                if bodyStart < buffer.count {
                    bodyBuffer.append(buffer[bodyStart...])
                }
            }
            
            // Read remaining body if needed
            while bodyBuffer.count < length {
                let chunk: Data? = await withCheckedContinuation { continuation in
                    connection.receive(minimumIncompleteLength: 1, maximumLength: length - bodyBuffer.count) { data, _, isComplete, _ in
                        if let data {
                            continuation.resume(returning: data)
                        } else if isComplete {
                            continuation.resume(returning: nil)
                        } else {
                            continuation.resume(returning: Data())
                        }
                    }
                }
                guard let chunk, !chunk.isEmpty else { break }
                bodyBuffer.append(chunk)
            }
            
            body = bodyBuffer
        }
        
        // 3) Route
        let response = Router.respond(method: method, path: path, body: body, headers: headers)

        // 3) Send and close
        await withCheckedContinuation { continuation in
            connection.send(content: response, completion: .contentProcessed { _ in continuation.resume() })
        }
        connection.cancel()
    }
}
