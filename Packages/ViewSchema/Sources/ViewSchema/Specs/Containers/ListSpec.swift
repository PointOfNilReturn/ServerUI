import Foundation

/// Specification for a List container view.
///
/// List displays a scrollable collection of views. It's optimized for displaying
/// collections of data and provides a familiar iOS list appearance.
///
/// ## JSON Structure
///
/// ```json
/// {
///   "type": {
///     "list": {}
///   },
///   "children": [
///     {/* row 1 */},
///     {/* row 2 */},
///     {/* row 3 */}
///   ]
/// }
/// ```
///
/// Each child becomes a row in the list.
///
/// - SeeAlso: `ViewType`, SwiftUI's `List`
public struct ListSpec: Codable, Equatable, Sendable, Hashable {
    /// Creates a list specification.
    public init() {}
}

