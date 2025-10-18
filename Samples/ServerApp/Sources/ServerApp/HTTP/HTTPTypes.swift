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
    
    static func parseHeaders(from raw: String) -> [String: String] {
        var headers: [String: String] = [:]
        let lines = raw.components(separatedBy: "\r\n")
        
        // Skip the request line (first line)
        for line in lines.dropFirst() {
            // Stop at empty line (marks end of headers)
            if line.isEmpty { break }
            
            // Parse header line (format: "Header-Name: value")
            guard let colonIndex = line.firstIndex(of: ":") else { continue }
            let key = String(line[..<colonIndex]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            headers[key] = value
        }
        
        return headers
    }
}
