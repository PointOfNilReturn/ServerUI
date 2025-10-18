import Foundation

/// Specification for a text field view.
///
/// TextField is an interactive control that allows users to input and edit text.
/// The text value is bound to server-side state via a binding.
///
/// ## JSON Structure
///
/// ```json
/// {
///   "type": {
///     "textField": {
///       "prompt": "Enter your name",
///       "stateKey": "state_MyView.swift_42"
///     }
///   }
/// }
/// ```
///
/// The `stateKey` identifies which @State variable the text is bound to.
///
/// ## State Updates
///
/// When the user types:
/// 1. Client updates local text immediately (optimistic update)
/// 2. Client debounces and sends state update to server
/// 3. Server updates the @State variable
/// 4. Server may re-render and send updated view (optional)
///
/// - SeeAlso: `ViewType`, SwiftUI's `TextField`
public struct TextFieldSpec: Codable, Equatable, Sendable, Hashable {
    /// The placeholder text to display when the field is empty.
    public let prompt: String
    
    /// The state key that this text field is bound to.
    ///
    /// This key corresponds to a @State variable on the server.
    /// When the user edits the text, the client sends updates to this key.
    public let stateKey: String
    
    /// The current value from the server.
    ///
    /// This is the server's source of truth. When the view re-renders, the client
    /// uses this value to update the text field, ensuring it stays in sync with server state.
    public let currentValue: String
    
    /// Creates a text field specification.
    ///
    /// - Parameters:
    ///   - prompt: The placeholder text.
    ///   - stateKey: The state key for the bound value.
    ///   - currentValue: The current value from the server's @State.
    public init(prompt: String, stateKey: String, currentValue: String) {
        self.prompt = prompt
        self.stateKey = stateKey
        self.currentValue = currentValue
    }
}

