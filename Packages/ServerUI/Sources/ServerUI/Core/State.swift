import Foundation

/// A property wrapper that manages state for a view.
///
/// Use `@State` to create mutable state that drives your view's appearance and behavior.
/// When state changes, ServerUI re-renders the view and sends updates to connected clients.
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
/// ## Server-Side State Management
///
/// Unlike SwiftUI where @State is view-local, ServerUI's @State:
/// - Persists in session storage on the server
/// - Survives view re-renders
/// - Can be shared across requests from the same session
/// - Requires `Codable` conformance for serialization
///
/// ## Access Control
///
/// Just like SwiftUI, mark state as `private` when it's implementation detail:
///
/// ```swift
/// @State private var isExpanded = false  // Implementation detail
/// @State var selectedItem: String?       // Part of public API
/// ```
///
/// - SeeAlso: `Binding`, `StateStore`
@propertyWrapper
public struct State<Value: Codable & Sendable>: Sendable {
    private let key: String
    private let defaultValue: Value
    
    /// The current value of the state.
    public var wrappedValue: Value {
        get {
            StateStore.current.get(key, default: defaultValue)
        }
        nonmutating set {
            StateStore.current.set(key, value: newValue)
        }
    }
    
    /// A binding to the state value.
    ///
    /// Use the projected value to pass a binding to child views:
    ///
    /// ```swift
    /// @State private var name = ""
    ///
    /// var body: some View {
    ///     TextField("Name", text: $name)  // $ accesses projectedValue
    /// }
    /// ```
    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
    
    /// Creates state with an initial value.
    ///
    /// The state key is generated deterministically using the file and line where the state is declared.
    /// This ensures that state persists across view re-creations within the same session.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value of the state.
    ///   - file: The file where the state is declared (automatically provided).
    ///   - line: The line where the state is declared (automatically provided).
    public init(wrappedValue: Value, file: String = #file, line: Int = #line) {
        // Generate deterministic key based on file and line
        // This ensures the same @State declaration always gets the same key
        let fileName = (file as NSString).lastPathComponent
        self.key = "state_\(fileName)_\(line)"
        self.defaultValue = wrappedValue
        
        // Register default value in state store
        StateStore.current.registerDefault(key, value: wrappedValue)
    }
}

/// A value and a way to mutate it.
///
/// Use a binding to create a two-way connection between a property and a view that
/// displays and mutates it. Changes made through the binding propagate back to the
/// source of truth.
///
/// ## Example
///
/// ```swift
/// struct NameEditor: View {
///     @Binding var name: String
///
///     var body: some View {
///         TextField("Name", text: $name)
///     }
/// }
/// ```
///
/// - SeeAlso: `State`
@propertyWrapper
public struct Binding<Value>: @unchecked Sendable {
    private let getValue: @Sendable () -> Value
    private let setValue: @Sendable (Value) -> Void
    
    /// The current value of the binding.
    public var wrappedValue: Value {
        get { getValue() }
        nonmutating set { setValue(newValue) }
    }
    
    /// A binding to the binding's value (returns self).
    public var projectedValue: Binding<Value> {
        self
    }
    
    /// Creates a binding with getter and setter closures.
    ///
    /// - Parameters:
    ///   - get: A closure that retrieves the current value.
    ///   - set: A closure that sets a new value.
    public init(get: @escaping @Sendable () -> Value, set: @escaping @Sendable (Value) -> Void) {
        self.getValue = get
        self.setValue = set
    }
}

/// Marker protocol for types that have dynamic properties.
///
/// Property wrappers like @State conform to this protocol.
public protocol DynamicProperty {}

extension State: DynamicProperty {}
extension Binding: DynamicProperty {}

