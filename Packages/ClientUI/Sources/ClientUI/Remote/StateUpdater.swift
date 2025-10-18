import Foundation
import SwiftUI
import ViewSchema
import Logging

/// Sends state updates to the server.
///
/// `StateUpdater` handles the client-side state synchronization flow:
///
/// 1. TextField changes locally (optimistic update)
/// 2. StateUpdater debounces the change (default: 300ms)
/// 3. Sends update to server's `/state` endpoint
/// 4. Server updates @State variable
///
/// ## Usage
///
/// `StateUpdater` is typically injected into the environment by `RemoteView`:
///
/// ```swift
/// RemoteView(configuration)
///     .environment(\.stateUpdater, updater)
/// ```
///
/// Components like `TextField` then access it via the environment.
///
/// - SeeAlso: `RemoteView`, `RemoteConfiguration`
@Observable @MainActor
public final class StateUpdater {
    /// Configuration for server communication.
    private let configuration: RemoteConfiguration
    
    /// Current session identifier.
    private let sessionId: String
    
    /// Debounce timer for text field updates.
    private var debounceTask: Task<Void, Never>?
    
    /// Debounce delay in seconds (default: 0.3 seconds).
    public var debounceDelay: TimeInterval = 0.3
    
    /// The most recently fetched view hierarchy after a state update.
    ///
    /// This property is automatically observed by SwiftUI views. When a state update
    /// completes and the server responds with an updated view, this value changes
    /// and triggers a re-render.
    public var latestViewHierarchy: ViewHierarchy?
    
    private let logger = Logger(label: "com.serverui.stateupdater")
    
    /// Creates a state updater.
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
    
    /// Updates a state value on the server with debouncing.
    ///
    /// This method cancels any pending update for the same state key and schedules
    /// a new update after the debounce delay.
    ///
    /// - Parameters:
    ///   - stateKey: The state key to update.
    ///   - value: The new value (as a string).
    public func updateState(_ stateKey: String, value: String) {
        // Cancel previous pending update
        debounceTask?.cancel()
        
        // Schedule new update after debounce delay
        debounceTask = Task {
            try? await Task.sleep(for: .seconds(debounceDelay))
            
            guard !Task.isCancelled else { return }
            
            await sendUpdate(stateKey: stateKey, value: value)
        }
    }
    
    /// Immediately sends a state update to the server without debouncing.
    ///
    /// - Parameters:
    ///   - stateKey: The state key to update.
    ///   - value: The new value (as a string).
    public func updateStateImmediately(_ stateKey: String, value: String) async {
        await sendUpdate(stateKey: stateKey, value: value)
    }
    
    /// Sends the state update to the server.
    ///
    /// - Parameters:
    ///   - stateKey: The state key to update.
    ///   - value: The new value.
    private func sendUpdate(stateKey: String, value: String) async {
        let stateURL = configuration.baseURL.appending(path: "state")
        
        var request = URLRequest(url: stateURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionId, forHTTPHeaderField: "X-Session-ID")
        
        // Encode state update request
        let updateRequest = StateUpdateRequest(
            sessionId: sessionId,
            stateKey: stateKey,
            value: value
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(updateRequest)
            
            logger.debug("Sending state update", metadata: [
                "stateKey": "\(stateKey)",
                "value": "\(value)",
                "url": "\(stateURL.absoluteString)"
            ])
            
            // Send request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response from state update")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                logger.error("State update failed", metadata: [
                    "statusCode": "\(httpResponse.statusCode)",
                    "stateKey": "\(stateKey)"
                ])
                return
            }
            
            // Decode updated view hierarchy from server
            let decoder = JSONDecoder()
            let envelope = try decoder.decode(ViewHierarchyEnvelope.self, from: data)
            
            logger.debug("State updated successfully, updating view", metadata: ["stateKey": "\(stateKey)"])
            
            // Update view hierarchy - SwiftUI will observe this change
            latestViewHierarchy = envelope.viewHierarchy
            
        } catch {
            logger.error("Failed to send state update", metadata: [
                "stateKey": "\(stateKey)",
                "error": "\(error.localizedDescription)"
            ])
        }
    }
}

/// State update request payload.
struct StateUpdateRequest: Codable {
    let sessionId: String
    let stateKey: String
    let value: String
}

/// Environment key for state updater.
struct StateUpdaterKey: EnvironmentKey {
    static let defaultValue: StateUpdater? = nil
}

public extension EnvironmentValues {
    /// The state updater for the current view hierarchy.
    var stateUpdater: StateUpdater? {
        get { self[StateUpdaterKey.self] }
        set { self[StateUpdaterKey.self] = newValue }
    }
}

