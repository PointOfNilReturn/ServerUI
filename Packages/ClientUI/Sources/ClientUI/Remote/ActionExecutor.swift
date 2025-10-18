import Foundation
import SwiftUI
import ViewSchema
import Logging

/// Executes server-side actions and manages view updates.
///
/// `ActionExecutor` handles the client-side action execution flow:
///
/// 1. Receives action ID from button tap
/// 2. Sends action request to server
/// 3. Receives updated view hierarchy
/// 4. Notifies the view system to re-render
///
/// ## Usage
///
/// `ActionExecutor` is typically injected into the environment by `RemoteView`:
///
/// ```swift
/// RemoteView(configuration)
///     .environment(\.actionExecutor, executor)
/// ```
///
/// Components like `ActionButton` then access it via the environment:
///
/// ```swift
/// @Environment(\.actionExecutor) private var actionExecutor
/// ```
///
/// ## Session Management
///
/// The executor maintains the session ID across action requests, ensuring that
/// actions are executed in the correct session context on the server.
///
/// - SeeAlso: `ActionButton`, `RemoteConfiguration`, `SessionContext`
@Observable @MainActor
public final class ActionExecutor {
    /// Configuration for server communication.
    private let configuration: RemoteConfiguration
    
    /// Current session identifier.
    private let sessionId: String
    
    /// The most recently fetched view hierarchy after an action.
    ///
    /// This property is automatically observed by SwiftUI views. When an action
    /// completes and updates this value, any view observing it will re-render.
    public var latestViewHierarchy: ViewHierarchy?
    
    private let logger = Logger(label: "com.serverui.actionexecutor")
    
    /// Creates an action executor.
    ///
    /// - Parameters:
    ///   - configuration: Server configuration.
    ///   - sessionId: Current session identifier.
    public init(
        configuration: RemoteConfiguration,
        sessionId: String
    ) {
        self.configuration = configuration
        self.sessionId = sessionId
    }
    
    /// Executes an action on the server.
    ///
    /// This method:
    /// 1. Constructs an action request with the session ID
    /// 2. Sends it to the server's action endpoint
    /// 3. Receives the updated view hierarchy
    /// 4. Triggers a re-render via the callback
    ///
    /// - Parameter actionId: The unique identifier of the action to execute.
    /// - Throws: `ActionExecutorError` if the request fails.
    public func execute(_ actionId: String) async throws {
        let actionURL = configuration.baseURL.appending(path: "action")
        
        var request = URLRequest(url: actionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionId, forHTTPHeaderField: "X-Session-ID")
        
        // Encode action request
        let actionRequest = ActionRequest(actionId: actionId, sessionId: sessionId)
        request.httpBody = try JSONEncoder().encode(actionRequest)
        
        logger.debug("Executing action", metadata: [
            "actionId": "\(actionId)",
            "sessionId": "\(sessionId)",
            "url": "\(actionURL.absoluteString)"
        ])
        
        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ActionExecutorError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            logger.error("Action execution failed", metadata: [
                "statusCode": "\(httpResponse.statusCode)",
                "actionId": "\(actionId)"
            ])
            throw ActionExecutorError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Decode updated view hierarchy
        let decoder = JSONDecoder()
        let envelope = try decoder.decode(ViewHierarchyEnvelope.self, from: data)
        
        logger.debug("Action executed successfully, updating view", metadata: [
            "actionId": "\(actionId)"
        ])
        
        // Update view hierarchy - SwiftUI will observe this change
        latestViewHierarchy = envelope.viewHierarchy
    }
}

/// Request payload for action execution.
struct ActionRequest: Codable {
    /// The action identifier to execute.
    let actionId: String
    
    /// The session identifier for context.
    let sessionId: String
}

/// Errors that can occur during action execution.
public enum ActionExecutorError: LocalizedError {
    /// The server response was not valid HTTP.
    case invalidResponse
    
    /// The server returned an HTTP error code.
    case httpError(statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "Server error: HTTP \(statusCode)"
        }
    }
}

/// Environment key for action executor.
struct ActionExecutorKey: EnvironmentKey {
    static let defaultValue: ActionExecutor? = nil
}

public extension EnvironmentValues {
    /// The action executor for the current view hierarchy.
    var actionExecutor: ActionExecutor? {
        get { self[ActionExecutorKey.self] }
        set { self[ActionExecutorKey.self] = newValue }
    }
}

