import Foundation

/// Specification for a ScrollView container.
///
/// ScrollView provides scrollable content in one or both axes.
///
/// ## JSON Structure
///
/// ```json
/// {
///   "type": {
///     "scrollView": {
///       "axes": "vertical"
///     }
///   },
///   "children": [
///     {/* content */}
///   ]
/// }
/// ```
///
/// - SeeAlso: `ViewType`, SwiftUI's `ScrollView`
public struct ScrollViewSpec: Codable, Equatable, Sendable, Hashable {
    /// The scroll axes.
    public let axes: ScrollAxes
    
    /// Creates a scroll view specification.
    ///
    /// - Parameter axes: The axes along which scrolling is allowed.
    public init(axes: ScrollAxes = .vertical) {
        self.axes = axes
    }
}

/// Axes along which scrolling is allowed.
public enum ScrollAxes: String, Codable, Equatable, Sendable, Hashable {
    /// Scroll vertically only.
    case vertical
    
    /// Scroll horizontally only.
    case horizontal
    
    /// Scroll in both directions.
    case both
}

