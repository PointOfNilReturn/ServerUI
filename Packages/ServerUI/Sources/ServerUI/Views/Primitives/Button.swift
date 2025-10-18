import ViewSchema

/// A control that performs an action when triggered.
///
/// Use a button to trigger actions in response to user interactions.
/// When the user taps a button, the associated action is sent to the server
/// and executed, potentially updating @State and triggering view re-renders.
///
/// ## Example
///
/// ```swift
/// struct CounterView: View {
///     @State private var count = 0
///
///     var body: some View {
///         VStack {
///             Text("Count: \(count)")
///             Button("Increment") {
///                 count += 1
///             }
///         }
///     }
/// }
/// ```
///
/// ## With Custom Label
///
/// ```swift
/// Button {
///     isExpanded.toggle()
/// } label: {
///     HStack {
///         Image(systemName: "chevron.right")
///         Text("Expand")
///     }
/// }
/// ```
///
/// ## Server-Side Actions
///
/// Unlike SwiftUI where button actions execute immediately, ServerUI buttons:
/// - Send the action ID to the server when tapped
/// - Execute the action closure on the server
/// - Re-render the view with updated state
/// - Send the updated JSON back to the client
///
/// This means button actions can:
/// - Mutate @State properties
/// - Make API calls
/// - Update databases
/// - Perform any server-side logic
///
/// - SeeAlso: `State`, `Action`
public struct Button<Label: View>: View, _ButtonProtocol {
    /// The button's label view.
    public let label: Label
    
    /// The action to execute when tapped.
    private let action: Action
    
    /// Creates a button with a custom label.
    ///
    /// - Parameters:
    ///   - action: The closure to execute when the button is tapped.
    ///   - label: A view builder that creates the button's label.
    public init(action: @escaping @Sendable () -> Void, @ViewBuilder label: () -> Label) {
        self.action = Action(execute: action)
        self.label = label()
        
        // Register action with the current registry
        ActionRegistry.current.register(self.action)
    }
    
    /// Button is a primitive, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the button's label and action ID for encoding.
    ///
    /// This method is used by the encoding engine to access the button's properties
    /// through protocol-based type erasure.
    ///
    /// - Returns: A tuple containing the label view and action ID (both type-erased).
    public func extractButton() -> (label: any View, actionId: ActionID) {
        return (label, action.id)
    }
}

// MARK: - Convenience Initializers

public extension Button where Label == Text {
    /// Creates a button with a text label.
    ///
    /// This is a convenience initializer for the common case of a simple text button.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Button("Tap Me") {
    ///     count += 1
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display on the button.
    ///   - action: The closure to execute when tapped.
    init(_ title: String, action: @escaping @Sendable () -> Void) {
        self.init(action: action) {
            Text(title)
        }
    }
}

