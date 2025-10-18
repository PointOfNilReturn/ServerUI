import Foundation
import ServerUI
import Logging

/// Handles state update requests from clients.
///
/// The StateUpdateHandler processes POST requests to `/state`, updates the specified
/// state variable within the correct session context, and optionally returns an
/// updated view hierarchy.
enum StateUpdateHandler {
    private static let logger = Logger(label: "com.serverui.stateupdatehandler")
    
    /// Handles a state update request.
    ///
    /// Expected request body:
    /// ```json
    /// {
    ///   "sessionId": "session_uuid_456",
    ///   "stateKey": "state_HomeScreen.swift_6",
    ///   "value": "John Doe"
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - body: The request body containing session ID, state key, and new value.
    ///   - headers: HTTP headers from the request.
    /// - Returns: HTTP response with success status or error.
    static func response(body: Data?, headers: [String: String]) -> Data {
        // Validate request body exists
        guard let body = body else {
            logger.warning("State update request received with no body")
            let errorBody = Data(#"{ "error": "missing request body" }"#.utf8)
            return HTTP.buildResponse(status: "400 Bad Request", body: errorBody)
        }
        
        // Parse state update request
        let decoder = JSONDecoder()
        let updateRequest: StateUpdateRequest
        do {
            updateRequest = try decoder.decode(StateUpdateRequest.self, from: body)
        } catch {
            logger.warning("Failed to decode state update request", metadata: ["error": "\(error.localizedDescription)"])
            let errorBody = Data(#"{ "error": "invalid request format" }"#.utf8)
            return HTTP.buildResponse(status: "400 Bad Request", body: errorBody)
        }
        
        logger.debug("Updating state", metadata: [
            "stateKey": "\(updateRequest.stateKey)",
            "sessionId": "\(updateRequest.sessionId)",
            "value": "\(updateRequest.value)"
        ])
        
        // Session is already activated by Router
        
        // Update the state value
        // Note: The value comes in as a string from JSON, but we store it as-is
        // The StateStore will cast it appropriately when retrieved
        StateStore.current.set(updateRequest.stateKey, value: updateRequest.value)
        
        logger.debug("State updated successfully")
        
        // For state updates (TextField changes), we don't re-render the entire view
        // The client handles optimistic updates via the OptimisticStateCache
        // We just confirm the state was updated successfully
        let successBody = Data(#"{ "success": true }"#.utf8)
        return HTTP.buildResponse(body: successBody)
    }
}

/// State update request payload.
private struct StateUpdateRequest: Codable {
    let sessionId: String
    let stateKey: String
    let value: String  // TextField values are always strings
}

