import Foundation
import ServerUI
import Logging

/// Handles navigation pop events from the client.
///
/// When a view is popped from the navigation stack, the client notifies the server
/// so that view-scoped state can be cleaned up.
enum NavigationPopHandler {
    private static let logger = Logger(label: "com.serverapp.navigationpophandler")
    
    static func response(body: Data?, headers: [String: String]) -> Data {
        guard let body else {
            logger.warning("No body in navigation pop request")
            let errorBody = Data(#"{ "error": "missing body" }"#.utf8)
            return HTTP.buildResponse(status: "400 Bad Request", body: errorBody)
        }
        
        // Decode the request
        let decoder = JSONDecoder()
        guard let popRequest = try? decoder.decode(NavigationPopRequest.self, from: body) else {
            logger.error("Failed to decode navigation pop request")
            let errorBody = Data(#"{ "error": "invalid request body" }"#.utf8)
            return HTTP.buildResponse(status: "400 Bad Request", body: errorBody)
        }
        
        logger.debug("Navigation popped", metadata: [
            "poppedPath": "\(popRequest.poppedPath)",
            "sessionId": "\(popRequest.sessionId)"
        ])
        
        // Session is already activated by Router
        
        // Clean up state for the popped path
        StateStore.current.clearPath(popRequest.poppedPath)
        
        logger.debug("State cleared for popped path", metadata: ["path": "\(popRequest.poppedPath)"])
        
        // Return success
        let successBody = Data(#"{ "success": true }"#.utf8)
        return HTTP.buildResponse(body: successBody)
    }
}

/// Request payload for navigation pop events.
private struct NavigationPopRequest: Codable {
    let poppedPath: String
    let sessionId: String
}

