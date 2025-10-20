import Foundation

/// Protocol that all remotely observable classes conform to.
///
/// This protocol provides a common interface for the observable infrastructure
/// to interact with observable objects without knowing their specific types.
///
/// The `@RemotelyObservable` macro automatically generates conformance to this protocol.
///
/// ## Manual Conformance
///
/// While the macro automates this, you can also conform manually:
///
/// ```swift
/// class UserProfile: @unchecked Sendable, RemotelyObservable {
///     var name: String = ""
///     
///     private let _objectID = UUID().uuidString
///     func _getObjectID() -> String { _objectID }
///     func _getProperties() -> [String: Any] { ["name": name] }
///     func _updateProperty(name: String, value: Any) {
///         // Handle updates...
///     }
/// }
/// ```
///
/// ## Usage with @RemotelyObservable Macro
///
/// ```swift
/// @RemotelyObservable
/// class UserProfile: @unchecked Sendable {
///     var name: String = ""
///     var email: String = ""
/// }
/// // All protocol methods generated automatically!
/// ```
public protocol RemotelyObservable: Sendable {
    /// Returns the unique ID for this observable object.
    func _getObjectID() -> String
    
    /// Returns all properties as a dictionary for serialization.
    func _getProperties() -> [String: Any]
    
    /// Updates a property by name.
    ///
    /// - Parameters:
    ///   - name: The property name
    ///   - value: The new value
    func _updateProperty(name: String, value: Any)
}

