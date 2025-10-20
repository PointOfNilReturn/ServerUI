import Foundation

/// A thread-safe store for managing @Observable objects in ServerUI.
///
/// ObservableStore tracks instances of @Observable classes, associating them with unique IDs
/// and managing their lifecycle. Objects are scoped to view instances (identified by path + view instance ID).
///
/// ## Usage
///
/// ```swift
/// @Observable
/// class UserProfile {
///     var name: String = ""
///     var email: String = ""
/// }
///
/// // In a view
/// @State private var profile = UserProfile()
/// ```
///
/// The store automatically manages the object's lifecycle, cleaning it up when the view is popped.
public final class ObservableStore: @unchecked Sendable {
    /// Shared instance for the current session.
    nonisolated(unsafe) public static var current: ObservableStore = ObservableStore()
    
    /// Current navigation path + view instance ID for scoping observables.
    nonisolated(unsafe) public static var currentPath: String = "/"
    
    /// Storage for observable objects, keyed by their unique ID.
    private var storage: [String: Any] = [:]
    
    /// Lock for thread-safe access.
    private let lock = NSLock()
    
    /// Creates a new observable store.
    public init() {}
    
    /// Registers an observable object with a unique key.
    ///
    /// - Parameters:
    ///   - key: The unique key for this observable (typically includes path, file, line)
    ///   - object: The observable object to store
    public func register<T>(_ key: String, object: T) {
        lock.lock()
        defer { lock.unlock() }
        storage[key] = object
    }
    
    /// Retrieves an observable object by its key.
    ///
    /// - Parameter key: The unique key for the observable
    /// - Returns: The observable object, or nil if not found
    public func get<T>(_ key: String) -> T? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key] as? T
    }
    
    /// Updates a property on an observable object.
    ///
    /// - Parameters:
    ///   - objectKey: The unique key for the observable object
    ///   - propertyPath: The property name (e.g., "name", "email")
    ///   - value: The new value to set
    public func updateProperty(objectKey: String, propertyPath: String, value: Any) {
        lock.lock()
        defer { lock.unlock() }
        
        print("🟡 ObservableStore.updateProperty: objectKey=\(objectKey), propertyPath=\(propertyPath), value=\(value)")
        
        // Get the object (classes are reference types, so we don't need 'var')
        guard let object = storage[objectKey] else { 
            print("❌ ObservableStore: Object not found for key \(objectKey)")
            print("   Available keys: \(storage.keys.joined(separator: ", "))")
            return 
        }
        
        print("✅ ObservableStore: Found object for key \(objectKey)")
        
        // Try to call the macro-generated _updateProperty method if available
        if let observable = object as? any RemotelyObservable {
            print("✅ ObservableStore: Calling _updateProperty on observable object")
            print("   Properties BEFORE update: \(observable._getProperties())")
            observable._updateProperty(name: propertyPath, value: value)
            print("   Properties AFTER update: \(observable._getProperties())")
            return
        }
        
        print("⚠️ ObservableStore: Object is not RemotelyObservable")
        
        // Fallback: Use Swift reflection to update the property
        // This works with any object, not just @ServerObservable ones
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            if child.label == propertyPath {
                // For classes, we need to use unsafe pointer manipulation
                // This is a limitation of Swift reflection - it can read but not write
                // For now, we'll rely on the macro-generated method above
                break
            }
        }
    }
    
    /// Clears all observables associated with a specific path.
    ///
    /// This is called when a view is popped from the navigation stack.
    ///
    /// - Parameter path: The path (including view instance ID) to clear
    public func clearPath(_ path: String) {
        lock.lock()
        defer { lock.unlock() }
        
        let keysToRemove = storage.keys.filter { $0.hasPrefix("\(path)::") }
        for key in keysToRemove {
            storage.removeValue(forKey: key)
        }
    }
    
    /// Retrieves all property values from an observable object as a dictionary.
    ///
    /// This is used when encoding the view hierarchy to serialize the current state.
    ///
    /// - Parameter key: The unique key for the observable object
    /// - Returns: A dictionary of property names to values
    public func getProperties(_ key: String) -> [String: Any] {
        lock.lock()
        defer { lock.unlock() }
        
        guard let object = storage[key] else { return [:] }
        
        // This will be implemented properly with reflection or a protocol
        // For now, return empty dictionary
        return [:]
    }
}

