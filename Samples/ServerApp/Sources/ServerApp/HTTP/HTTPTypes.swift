import Foundation

enum HTTP {
    static func buildResponse(
        status: String = "200 OK",
        contentType: String = "application/json",
        body: Data
    ) -> Data {
        var headers = "HTTP/1.1 \(status)\r\n"
        headers += "Content-Type: \(contentType)\r\n"
        headers += "Content-Length: \(body.count)\r\n"
        headers += "Connection: close\r\n\r\n"
        var bytes = Data(headers.utf8)
        bytes.append(body)
        return bytes
    }

    static func parseRequestLine(from raw: String) -> (method: String, path: String)? {
        guard let first = raw.components(separatedBy: "\r\n").first else { return nil }
        let parts = first.split(separator: " ")
        guard parts.count >= 2 else { return nil }
        return (String(parts[0]), String(parts[1]))
    }
}
