import Foundation

/// A property wrapper that manages state for a view.
///
/// Use `@State` to create mutable state that drives your view's appearance and behavior.
/// When state changes, ServerUI re-renders the view and sends updates to connected clients.
///
/// `@State` works with BOTH value types and observable objects, just like vanilla SwiftUI:
///
/// ## Value Types
///
/// ```swift
/// @State private var count = 0
/// @State private var name = ""
/// @State private var isExpanded = false
/// ```
///
/// ## Observable Objects
///
/// ```swift
/// @RemotelyObservable
/// class UserProfile {
///     var name: String = ""
/// }
///
/// @State private var profile = UserProfile()  // ← Works with objects too!
/// ```
///
/// ## Server-Side State Management
///
/// Unlike SwiftUI where @State is view-local, ServerUI's @State:
/// - Persists in session storage on the server
/// - Survives view re-renders
/// - Is scoped to specific view instances (cleaned up when view is popped)
/// - Value types require `Codable` conformance for serialization
/// - Observable objects are stored by reference in `ObservableStore`
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
/// - SeeAlso: `Binding`, `@RemotelyObservable`, `@Bindable`
@propertyWrapper
public struct State<Value: Sendable>: Sendable {
    private let key: String
    private let factory: @Sendable () -> Value
    private let isObjectType: Bool
    
    /// The current value of the state.
    public var wrappedValue: Value {
        get {
            if isObjectType {
                // For observable objects, use the object's _objectID as the key
                // First, check if we already have an object stored
                if let existing: Value = ObservableStore.current.get(key) {
                    return existing
                }
                // Create the object
                let newObject = factory()
                // Get the object's actual ID
                let objectKey: String
                if let observable = newObject as? any RemotelyObservable {
                    objectKey = observable._getObjectID()
                    print("🟢 State: Created observable object with objectKey = \(objectKey), stateKey = \(key)")
                } else {
                    objectKey = key // Fallback
                    print("🟢 State: Created non-observable object with key = \(key)")
                }
                // Store it with the object's ID
                ObservableStore.current.register(objectKey, object: newObject)
                // Also store the mapping so we can find it again
                ObservableStore.current.register(key, object: newObject)
                return newObject
            } else {
                // For value types, use StateStore with Codable
                if let codableValue = Value.self as? any Codable.Type {
                    // We have Codable, use StateStore
                    let defaultValue = factory()
                    if let stored = StateStore.current.get(key, default: defaultValue as! (any Codable)) as? Value {
                        return stored
                    }
                    return defaultValue
                } else {
                    // Non-codable value type - just return factory value
                    // (This shouldn't happen in practice, but handle gracefully)
                    return factory()
                }
            }
        }
        nonmutating set {
            if isObjectType {
                // For objects, update in ObservableStore using both keys
                let objectKey: String
                if let observable = newValue as? any RemotelyObservable {
                    objectKey = observable._getObjectID()
                } else {
                    objectKey = key
                }
                ObservableStore.current.register(objectKey, object: newValue)
                ObservableStore.current.register(key, object: newValue)
            } else {
                // For value types, update in StateStore
                if let codableValue = newValue as? any Codable {
                    StateStore.current.set(key, value: codableValue)
                }
            }
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
    ///
    /// For observable objects, you typically use `@Bindable` instead of bindings:
    ///
    /// ```swift
    /// @State private var profile = UserProfile()
    ///
    /// var body: some View {
    ///     ProfileEditor(profile: profile)  // Pass object directly
    /// }
    ///
    /// struct ProfileEditor: View {
    ///     @Bindable var profile: UserProfile  // Use @Bindable to create bindings
    ///     
    ///     var body: some View {
    ///         TextField("Name", text: $profile.name)  // $profile.name is a binding
    ///     }
    /// }
    /// ```
    public var projectedValue: Binding<Value> {
        Binding(
            stateKey: key,
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
    
    /// Creates state with an initial value.
    ///
    /// The state key is generated deterministically using the current path, file, and line.
    /// This ensures that state is scoped to the specific view instance (navigation path) and
    /// persists across re-renders but is cleaned up when the view is popped.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value of the state.
    ///   - file: The file where the state is declared (automatically provided).
    ///   - line: The line where the state is declared (automatically provided).
    public init(wrappedValue: @autoclosure @escaping @Sendable () -> Value, file: String = #file, line: Int = #line) {
        // Generate deterministic key based on path, file, and line
        let fileName = (file as NSString).lastPathComponent
        let fullPath = StateStore.currentPath.isEmpty ? ObservableStore.currentPath : StateStore.currentPath
        
        // Determine if this is an object type (class) or value type (struct/enum/primitive)
        self.isObjectType = type(of: wrappedValue()) is AnyObject.Type
        
        // Use full path including view instance ID
        // This ensures each navigation gets a fresh object/state
        self.key = "\(fullPath)::state_\(fileName)_\(line)"
        self.factory = wrappedValue
        
        // For value types, register default if Codable
        if !isObjectType {
            let defaultValue = wrappedValue()
            if let codable = defaultValue as? any Codable {
                StateStore.current.registerDefault(key, value: codable)
            }
        }
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
/// Bindings can be created from `@State` or `@Bindable`:
/// - `@State var name` → `$name` creates a binding to simple state
/// - `@Bindable var profile` → `$profile.name` creates a binding to an observable property
///
/// - SeeAlso: `State`, `@Bindable`, `ObservableStore`
@propertyWrapper
public struct Binding<Value>: @unchecked Sendable {
    private let getValue: @Sendable () -> Value
    private let setValue: @Sendable (Value) -> Void
    
    /// The state key that this binding is connected to.
    ///
    /// For simple @State bindings, this is the state key.
    /// For @Bindable bindings, this is combined with objectKey and propertyPath.
    public let stateKey: String
    
    /// The observable object key (if this binding is to an observable property).
    public let objectKey: String?
    
    /// The property path within the observable object (if applicable).
    public let propertyPath: String?
    
    /// The current value of the binding.
    public var wrappedValue: Value {
        get { getValue() }
        nonmutating set { setValue(newValue) }
    }
    
    /// A binding to the binding's value (returns self).
    public var projectedValue: Binding<Value> {
        self
    }
    
    /// Creates a binding with a state key, getter, and setter closures.
    ///
    /// This initializer is used for simple `@State` bindings.
    ///
    /// - Parameters:
    ///   - stateKey: The state key this binding is connected to.
    ///   - get: A closure that retrieves the current value.
    ///   - set: A closure that sets a new value.
    public init(stateKey: String = "", get: @escaping @Sendable () -> Value, set: @escaping @Sendable (Value) -> Void) {
        self.stateKey = stateKey
        self.objectKey = nil
        self.propertyPath = nil
        self.getValue = get
        self.setValue = set
    }
    
    /// Creates a binding to an observable object's property.
    ///
    /// This initializer is used for `@Bindable` bindings like `$profile.name`.
    ///
    /// - Parameters:
    ///   - objectKey: The unique key identifying the observable object
    ///   - propertyPath: The property name within the object (e.g., "name", "email")
    ///   - get: A closure that retrieves the current property value
    ///   - set: A closure that sets a new property value
    public init(objectKey: String, propertyPath: String, get: @escaping @Sendable () -> Value, set: @escaping @Sendable (Value) -> Void) {
        // For observable bindings, combine object key and property path into state key
        self.stateKey = "\(objectKey)::\(propertyPath)"
        self.objectKey = objectKey
        self.propertyPath = propertyPath
        self.getValue = get
        self.setValue = set
    }
    
    /// Internal initializer for observable bindings that allows non-Sendable closures.
    ///
    /// This is safe for observable objects because they're only accessed on the server
    /// and the closures are never sent across isolation boundaries.
    ///
    /// - Parameters:
    ///   - objectKey: The unique key identifying the observable object
    ///   - propertyPath: The property name within the object
    ///   - get: A closure that retrieves the current property value
    ///   - set: A closure that sets a new property value
    ///   - unchecked: Marker parameter to distinguish from public initializer
    internal init(objectKey: String, propertyPath: String, get: @escaping () -> Value, set: @escaping (Value) -> Void, unchecked: Bool = true) {
        // For observable bindings, combine object key and property path into state key
        self.stateKey = "\(objectKey)::\(propertyPath)"
        self.objectKey = objectKey
        self.propertyPath = propertyPath
        // Use unchecked conversion since we know this is safe for server-side use
        self.getValue = unsafeBitCast(get, to: (@Sendable () -> Value).self)
        self.setValue = unsafeBitCast(set, to: (@Sendable (Value) -> Void).self)
    }
}

/// Marker protocol for types that have dynamic properties.
///
/// Property wrappers like @State conform to this protocol.
public protocol DynamicProperty {}

extension State: DynamicProperty {}
extension Binding: DynamicProperty {}
