import Foundation

/// Specification for a navigation stack container.
///
/// NavigationStack provides a stack-based navigation interface where views can be pushed
/// and popped from the navigation hierarchy.
///
/// Corresponds to SwiftUI's `NavigationStack` type (iOS 16+).
///
/// ## JSON Encoding
///
/// ```json
/// {
///   "type": {
///     "navigationStack": {}
///   },
///   "children": [/* root view */]
/// }
/// ```
///
/// ## Usage
///
/// ```swift
/// NavigationStack {
///     VStack {
///         Text("Home Screen")
///         NavigationLink("Go to Details") {
///             Text("Details Screen")
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: `NavigationLinkSpec`, SwiftUI's `NavigationStack`
public struct NavigationStackSpec: Codable, Equatable, Sendable {
    /// Creates a navigation stack specification.
    public init() {}
}

