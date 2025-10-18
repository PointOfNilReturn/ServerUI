import Foundation

/// Specification for a button view.
///
/// Button is an interactive primitive that triggers server-side actions when tapped.
///
/// ## JSON Structure
///
/// ```json
/// {
///   "type": {
///     "button": {
///       "actionId": "action_uuid_123"
///     }
///   },
///   "children": [
///     {/* label view */}
///   ]
/// }
/// ```
///
/// The label is encoded as the first (and only) child node.
///
/// ## Action Execution
///
/// When the client taps the button:
/// 1. Client sends action request with the actionId
/// 2. Server executes the registered action
/// 3. Server re-renders the view with updated state
/// 4. Server responds with updated JSON
///
/// - SeeAlso: `ViewType`, SwiftUI's `Button`
public struct ButtonSpec: Codable, Equatable, Sendable, Hashable {
    /// The unique identifier for the action to execute when tapped.
    public let actionId: String
    
    /// Creates a button specification.
    ///
    /// - Parameter actionId: The action identifier.
    public init(actionId: String) {
        self.actionId = actionId
    }
}

