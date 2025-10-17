import Foundation

/// Specification for a navigation link.
///
/// NavigationLink creates a button that navigates to a destination view when tapped.
/// In the JSON encoding, the first child is the label (what's displayed), and the
/// second child is the destination view (where navigation goes).
///
/// Corresponds to SwiftUI's `NavigationLink` type.
///
/// ## JSON Encoding
///
/// ```json
/// {
///   "type": {
///     "navigationLink": {}
///   },
///   "children": [
///     {/* label view */},
///     {/* destination view */}
///   ]
/// }
/// ```
///
/// ## Usage
///
/// ```swift
/// NavigationLink {
///     Text("Go to Details")
/// } destination: {
///     DetailView()
/// }
/// ```
///
/// Or with the convenience initializer:
///
/// ```swift
/// NavigationLink("Go to Details") {
///     DetailView()
/// }
/// ```
///
/// - SeeAlso: `NavigationStackSpec`, SwiftUI's `NavigationLink`
public struct NavigationLinkSpec: Codable, Equatable, Sendable {
    /// Creates a navigation link specification.
    public init() {}
}

