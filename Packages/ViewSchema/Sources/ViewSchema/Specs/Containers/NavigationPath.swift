import Foundation

/// A type-safe representation of a navigation path.
///
/// Use `NavigationPath` to construct paths in a type-safe manner when creating
/// path-based navigation links.
///
/// ## Usage
///
/// ```swift
/// NavigationLink("Profile", path: .path("/screen/profile"))
/// NavigationLink("User", path: .pathWithQuery("/profile", query: ["id": "123"]))
/// ```
///
/// - SeeAlso: `NavigationLinkSpec`
public enum NavigationPath: Equatable, Sendable {
    /// A path without query parameters.
    ///
    /// Example: `.path("/screen/profile")`
    case path(String)
    
    /// A path with query parameters.
    ///
    /// Example: `.pathWithQuery("/profile", query: ["id": "123"])`
    case pathWithQuery(String, query: [String: String])
    
    /// Converts this navigation path to a `NavigationLinkSpec`.
    ///
    /// - Returns: The corresponding `NavigationLinkSpec` case.
    public func toSpec() -> NavigationLinkSpec {
        switch self {
        case .path(let path):
            return .path(path)
        case .pathWithQuery(let path, let query):
            return .pathWithQuery(path: path, query: query)
        }
    }
}

/// Helper extensions for building query strings in a type-safe manner.
public extension NavigationPath {
    /// Creates a path with a single query parameter.
    ///
    /// - Parameters:
    ///   - path: The path.
    ///   - key: The query parameter key.
    ///   - value: The query parameter value.
    /// - Returns: A navigation path with the query parameter.
    static func path(_ path: String, _ key: String, _ value: String) -> NavigationPath {
        .pathWithQuery(path, query: [key: value])
    }
}

