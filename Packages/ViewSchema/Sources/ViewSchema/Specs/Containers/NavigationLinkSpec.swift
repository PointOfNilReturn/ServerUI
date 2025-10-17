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
/// // Absolute path
/// NavigationLink("Profile", absolutePath: "/screen/profile")
///
/// // Relative path
/// NavigationLink("Settings", relativePath: "settings")
///
/// // With query parameters
/// NavigationLink("User", absolutePath: "/profile", query: ["id": "123"])
/// ```
///
/// - SeeAlso: `NavigationStackSpec`, `NavigationPath`, SwiftUI's `NavigationLink`
public enum NavigationLinkSpec: Codable, Equatable, Sendable, Hashable {
    /// Embedded destination view (encoded in JSON).
    ///
    /// The destination view is fully encoded as a child node.
    /// Best for simple, static screens.
    case embedded
    
    /// Absolute path without query parameters.
    ///
    /// Example: `/screen/profile`
    case absolutePath(String)
    
    /// Relative path without query parameters.
    ///
    /// Resolved relative to the current screen's path.
    /// Example: `details` (from `/screen/home` → `/screen/home/details`)
    case relativePath(String)
    
    /// Absolute path with query parameters.
    ///
    /// Example: `/profile` with `["id": "123"]` → `/profile?id=123`
    case absolutePathWithQuery(path: String, query: [String: String])
    
    /// Relative path with query parameters.
    ///
    /// Example: `details` with `["tab": "info"]` → `details?tab=info`
    case relativePathWithQuery(path: String, query: [String: String])
}

