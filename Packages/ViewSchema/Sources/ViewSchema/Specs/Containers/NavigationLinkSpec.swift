import Foundation

/// Specification for a navigation link.
///
/// NavigationLink creates a button that navigates to a destination view when tapped.
/// Supports two navigation modes:
/// - **Embedded**: Destination view is encoded in the JSON (mirrors SwiftUI exactly)
/// - **Path-based**: Destination is fetched on-demand from a server path
///
/// Corresponds to SwiftUI's `NavigationLink` type.
///
/// ## Embedded Navigation
///
/// The destination view is included in the JSON payload:
///
/// ```swift
/// NavigationLink("Details") {
///     DetailView()  // Encoded immediately
/// }
/// ```
///
/// ## Path-Based Navigation
///
/// The destination is fetched lazily when the link is tapped:
///
/// ```swift
/// NavigationLink("Profile", path: "/screen/profile")
/// NavigationLink("User", path: "/profile", query: ["id": "123"])
/// ```
///
/// - SeeAlso: `NavigationStackSpec`, `NavigationPath`, SwiftUI's `NavigationLink`
public enum NavigationLinkSpec: Codable, Equatable, Sendable, Hashable {
    /// Embedded destination view (encoded in JSON).
    ///
    /// The destination view is fully encoded as a child node.
    /// Best for simple, static screens.
    case embedded
    
    /// Path without query parameters.
    ///
    /// Example: `/screen/profile`
    case path(String)
    
    /// Path with query parameters.
    ///
    /// Example: `/profile` with `["id": "123"]` → `/profile?id=123`
    case pathWithQuery(path: String, query: [String: String])
}

