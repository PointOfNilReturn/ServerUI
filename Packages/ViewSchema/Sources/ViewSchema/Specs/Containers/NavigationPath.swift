import Foundation

/// A type-safe representation of a navigation path.
///
/// Use `NavigationPath` to construct paths in a type-safe manner when creating
/// path-based navigation links.
///
/// ## Usage
///
/// ```swift
/// NavigationLink("Profile", path: .absolute("/screen/profile"))
/// NavigationLink("Details", path: .relative("details"))
/// NavigationLink("User", path: .absoluteWithQuery("/profile", query: ["id": "123"]))
/// ```
///
/// - SeeAlso: `NavigationLinkSpec`
public enum NavigationPath: Equatable, Sendable {
    /// An absolute path without query parameters.
    ///
    /// Example: `.absolute("/screen/profile")`
    case absolute(String)
    
    /// A relative path without query parameters.
    ///
    /// Example: `.relative("settings")`
    case relative(String)
    
    /// An absolute path with query parameters.
    ///
    /// Example: `.absoluteWithQuery("/profile", query: ["id": "123"])`
    case absoluteWithQuery(String, query: [String: String])
    
    /// A relative path with query parameters.
    ///
    /// Example: `.relativeWithQuery("details", query: ["tab": "info"])`
    case relativeWithQuery(String, query: [String: String])
    
    /// Converts this navigation path to a `NavigationLinkSpec`.
    ///
    /// - Returns: The corresponding `NavigationLinkSpec` case.
    public func toSpec() -> NavigationLinkSpec {
        switch self {
        case .absolute(let path):
            return .absolutePath(path)
        case .relative(let path):
            return .relativePath(path)
        case .absoluteWithQuery(let path, let query):
            return .absolutePathWithQuery(path: path, query: query)
        case .relativeWithQuery(let path, let query):
            return .relativePathWithQuery(path: path, query: query)
        }
    }
}

/// Helper extensions for building query strings in a type-safe manner.
public extension NavigationPath {
    /// Creates an absolute path with a single query parameter.
    ///
    /// - Parameters:
    ///   - path: The absolute path.
    ///   - key: The query parameter key.
    ///   - value: The query parameter value.
    /// - Returns: A navigation path with the query parameter.
    static func absolute(_ path: String, _ key: String, _ value: String) -> NavigationPath {
        .absoluteWithQuery(path, query: [key: value])
    }
    
    /// Creates a relative path with a single query parameter.
    ///
    /// - Parameters:
    ///   - path: The relative path.
    ///   - key: The query parameter key.
    ///   - value: The query parameter value.
    /// - Returns: A navigation path with the query parameter.
    static func relative(_ path: String, _ key: String, _ value: String) -> NavigationPath {
        .relativeWithQuery(path, query: [key: value])
    }
}

