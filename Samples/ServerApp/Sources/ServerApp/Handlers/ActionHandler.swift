import Foundation
import ServerUI
import Logging

/// Handles action execution requests from clients.
///
/// The ActionHandler processes POST requests to `/action`, executes the requested action
/// within the correct session context, and returns the updated view hierarchy.
enum ActionHandler {
    private static let logger = Logger(label: "com.serverui.actionhandler")
    
    /// Handles an action execution request.
    ///
    /// Expected request body:
    /// ```json
    /// {
    ///   "actionId": "action_uuid_123",
    ///   "sessionId": "session_uuid_456"
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - body: The request body containing action ID and session ID.
    ///   - headers: HTTP headers from the request.
    /// - Returns: HTTP response with updated view hierarchy or error.
    static func response(body: Data?, headers: [String: String]) -> Data {
        // Validate request body exists
        guard let body = body else {
            logger.warning("Action request received with no body")
            let errorBody = Data(#"{ "error": "missing request body" }"#.utf8)
            return HTTP.buildResponse(status: "400 Bad Request", body: errorBody)
        }
        
        // Parse action request
        let decoder = JSONDecoder()
        let actionRequest: ActionRequest
        do {
            actionRequest = try decoder.decode(ActionRequest.self, from: body)
        } catch {
            logger.warning("Failed to decode action request", metadata: ["error": "\(error.localizedDescription)"])
            let errorBody = Data(#"{ "error": "invalid request format" }"#.utf8)
            return HTTP.buildResponse(status: "400 Bad Request", body: errorBody)
        }
        
        logger.info("Executing action", metadata: [
            "actionId": "\(actionRequest.actionId)",
            "sessionId": "\(actionRequest.sessionId)"
        ])
        
        // Session is already activated by Router
        
        // Execute the action
        let success = ActionRegistry.current.execute(actionRequest.actionId)
        
        guard success else {
            logger.error("Action not found", metadata: ["actionId": "\(actionRequest.actionId)"])
            let errorBody = Data(#"{ "error": "action not found" }"#.utf8)
            return HTTP.buildResponse(status: "404 Not Found", body: errorBody)
        }
        
        // Action executed successfully - re-render the view with updated state
        logger.debug("Action executed successfully, re-rendering view for path: \(actionRequest.currentPath)")
        
        // Route to the correct handler based on the current path
        return Router.respond(method: "GET", path: actionRequest.currentPath, body: nil, headers: headers)
    }
}

/// Action request payload.
private struct ActionRequest: Codable {
    let actionId: String
    let sessionId: String
    let currentPath: String
}

