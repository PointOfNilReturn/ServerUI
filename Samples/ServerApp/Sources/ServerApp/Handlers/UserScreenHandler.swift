import Foundation
import ServerUI

enum UserScreenHandler {
    static func response(path: String) -> Data {
        // Parse query parameters
        let userId = extractQueryParam(from: path, key: "id") ?? "unknown"
        let body = (try? ServerUIJSON.encode(UserScreen(userId: userId, fullPath: path))) ?? Data(#"{ "error":"encode failed" }"#.utf8)
        return HTTP.buildResponse(status: "200 OK", contentType: "application/json", body: body)
    }
    
    private static func extractQueryParam(from path: String, key: String) -> String? {
        guard let queryStart = path.firstIndex(of: "?") else { return nil }
        let query = path[path.index(after: queryStart)...]
        
        let pairs = query.split(separator: "&")
        for pair in pairs {
            let components = pair.split(separator: "=", maxSplits: 1)
            if components.count == 2, components[0] == key {
                return String(components[1])
            }
        }
        return nil
    }
}

private struct UserScreen: View {
    let userId: String
    let fullPath: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(verbatim: "👥")
                .font(.largeTitle)
                .padding()
            
            Text(verbatim: "User Details")
                .font(.largeTitle)
            
            Text(verbatim: "Query parameter example")
                .font(.body)
                .padding()
            
            VStack(spacing: 12) {
                HStack {
                    Text(verbatim: "User ID:")
                        .font(.headline)
                    Text(verbatim: userId)
                        .font(.body)
                }
                
                Text(verbatim: "Full path:")
                    .font(.caption)
                Text(verbatim: fullPath)
                    .font(.footnote)
            }
            .padding()
            
            Text(verbatim: "This demonstrates query parameter support in path-based navigation")
                .font(.caption)
                .padding(.top, 20)
        }
        .padding()
        .navigationTitle("User \(userId)")
    }
}

