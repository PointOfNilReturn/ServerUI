import ViewSchema

/// A control that displays an editable text interface.
///
/// Use a text field to allow users to input and edit text. The text value
/// is bound to a @State variable on the server, enabling two-way data flow.
///
/// ## Example
///
/// ```swift
/// struct FormView: View {
///     @State private var name: String = ""
///     @State private var email: String = ""
///
///     var body: some View {
///         VStack {
///             TextField("Name", text: $name)
///             TextField("Email", text: $email)
///             
///             Button("Submit") {
///                 print("Name: \(name), Email: \(email)")
///             }
///         }
///     }
/// }
/// ```
///
/// ## Server-Side Binding
///
/// Unlike SwiftUI where text fields update state immediately, ServerUI text fields:
/// - Send debounced updates to the server as the user types
/// - Update the bound @State variable on the server
/// - The server can optionally re-render the view with updated state
///
/// ## Client-Side Behavior
///
/// The client implements optimistic updates:
/// 1. User types → local text updates immediately (feels responsive)
/// 2. After a short delay (default: 300ms) → sends update to server
/// 3. Server updates @State and can trigger re-render if needed
///
/// - SeeAlso: `State`, `Binding`
public struct TextField: View, _TextFieldProtocol {
    /// The prompt text to display when the field is empty.
    public let prompt: String
    
    /// The binding to the text value.
    private let textBinding: Binding<String>
    
    /// Creates a text field with a prompt and text binding.
    ///
    /// - Parameters:
    ///   - prompt: The placeholder text to show when empty.
    ///   - text: A binding to the text value.
    public init(_ prompt: String, text: Binding<String>) {
        self.prompt = prompt
        self.textBinding = text
    }
    
    /// TextField is a primitive, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the text field's prompt, state key, and current value for encoding.
    ///
    /// This method is used by the encoding engine to access the text field's properties
    /// through protocol-based type erasure.
    ///
    /// - Returns: A tuple containing the prompt, state key, and current value.
    public func extractTextField() -> (prompt: String, stateKey: String, currentValue: String) {
        // Extract the state key and current value from the binding
        let stateKey = textBinding.stateKey
        let currentValue = textBinding.wrappedValue
        return (prompt, stateKey, currentValue)
    }
}

