import Foundation

/// Represents the complete view hierarchy and initial state for a screen.
///
/// The view hierarchy includes both the tree of views and the initial values
/// of all state that the views need. This allows the client to initialize a
/// reactive cache with current values, enabling instant UI updates while
/// the server remains the source of truth.
public struct ViewHierarchy: Codable, Sendable, Equatable, Hashable {
    /// The root view node of the hierarchy.
    public let root: ViewNode
    
    /// Initial state values for this view hierarchy.
    ///
    /// Maps state keys (e.g., "objectID::propertyName") to their current values.
    /// The client uses this to initialize its reactive cache, allowing instant
    /// UI updates while changes are synced to the server in the background.
    ///
    /// Format:
    /// - For `@State`: `"path::state_File.swift_42" → "value"`
    /// - For `@RemotelyObservable`: `"objectID::propertyName" → "value"`
    public let initialState: [String: StateValue]

    public init(root: ViewNode, initialState: [String: StateValue] = [:]) {
        self.root = root
        self.initialState = initialState
    }
}

/// A type-erased container for state values that can be encoded/decoded.
///
/// Supports common types used in UI state: String, Int, Double, Bool.
public enum StateValue: Codable, Sendable, Equatable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported state value type"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
    
    /// Extracts the value as an Any for use in the state cache.
    public var anyValue: Any? {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .bool(let value):
            return value
        case .null:
            return nil
        }
    }
}
