import Foundation

/// A property wrapper that creates bindings to properties of an observable object.
///
/// Use `@Bindable` in views to create two-way bindings to properties of `@Observable` objects.
/// This mirrors SwiftUI's `@Bindable` functionality.
///
/// ## Usage
///
/// ```swift
/// @Observable
/// class UserProfile {
///     var name: String = ""
///     var email: String = ""
///     var age: Int = 0
/// }
///
/// struct ProfileForm: View {
///     @Bindable var profile: UserProfile
///     
///     var body: some View {
///         VStack {
///             TextField("Name", text: $profile.name)
///             TextField("Email", text: $profile.email)
///             Text("Age: \(profile.age)")
///         }
///     }
/// }
/// ```
///
/// ## How It Works
///
/// - The `@Bindable` wrapper holds a reference to the observable object
/// - The `$` syntax creates `Binding<T>` instances for individual properties
/// - Each binding includes the object key and property path for server-side updates
///
/// - SeeAlso: `Binding`, `@State`, `ObservableStore`
@propertyWrapper
public struct Bindable<ObjectType: Sendable>: Sendable {
    /// The observable object being bound to.
    public let wrappedValue: ObjectType
    
    /// The unique key identifying this observable object in the store.
    let objectKey: String
    
    /// Creates a bindable wrapper for an observable object.
    ///
    /// - Parameter wrappedValue: The observable object to bind to
    public init(wrappedValue: ObjectType) {
        self.wrappedValue = wrappedValue
        // Get the object's actual ID from the RemotelyObservable protocol
        if let observable = wrappedValue as? any RemotelyObservable {
            self.objectKey = observable._getObjectID()
        } else {
            // Fallback for non-observable objects (shouldn't happen in practice)
            self.objectKey = String(describing: ObjectIdentifier(wrappedValue as AnyObject))
        }
    }
    
    /// Internal initializer with explicit object key.
    ///
    /// This is used when passing an observable object from a parent view
    /// that already has a registered key.
    init(wrappedValue: ObjectType, objectKey: String) {
        self.wrappedValue = wrappedValue
        self.objectKey = objectKey
    }
    
    /// The projected value provides access to bindings for the object's properties.
    ///
    /// This enables the `$profile.name` syntax.
    public var projectedValue: BindableObject<ObjectType> {
        BindableObject(object: wrappedValue, objectKey: objectKey)
    }
}

/// A wrapper that provides binding access to an observable object's properties.
///
/// This is the projected value of `@Bindable`, accessed via the `$` syntax.
/// It allows creating `Binding` instances to individual properties.
@dynamicMemberLookup
public struct BindableObject<ObjectType: Sendable>: Sendable {
    /// The observable object.
    let object: ObjectType
    
    /// The unique key for this object in the observable store.
    let objectKey: String
    
    /// Creates a binding to a specific property of the observable object.
    ///
    /// This uses dynamic member lookup to enable syntax like `$profile.name`.
    ///
    /// - Parameter keyPath: The key path to the property
    /// - Returns: A binding to that property
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<ObjectType, Value>) -> Binding<Value> {
        // Extract the property name from the key path
        let propertyName = extractPropertyName(from: keyPath)
        
        // Use internal initializer that allows non-Sendable closures
        // This is safe because observable objects are only used server-side
        return Binding(
            objectKey: objectKey,
            propertyPath: propertyName,
            get: { [object] in object[keyPath: keyPath] },
            set: { _ in /* Updates handled by server */ },
            unchecked: true
        )
    }
    
    /// Extracts the property name from a key path.
    ///
    /// This is a simplified implementation. In practice, you'd use
    /// reflection or store property names explicitly.
    private func extractPropertyName<Value>(from keyPath: WritableKeyPath<ObjectType, Value>) -> String {
        // This is a placeholder - actual implementation would extract the property name
        // For now, we'll use the keyPath's description as a fallback
        return String(describing: keyPath).components(separatedBy: ".").last ?? "unknown"
    }
}


