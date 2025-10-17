/// Horizontal alignment options for views in a vertical stack.
///
/// Corresponds to SwiftUI's `HorizontalAlignment` type.
///
/// ## Usage
///
/// ```swift
/// VStack(alignment: .leading) {
///     Text("Left aligned")
///     Text("Also left")
/// }
/// ```
///
/// - SeeAlso: `VStackSpec`, SwiftUI's `HorizontalAlignment`
public enum HorizontalAlignmentSpec: String, Codable, Equatable, Sendable {
    /// Aligns views to their leading edge (left in LTR, right in RTL).
    case leading
    
    /// Centers views horizontally.
    case center
    
    /// Aligns views to their trailing edge (right in LTR, left in RTL).
    case trailing
}

/// Vertical alignment options for views in a horizontal stack.
///
/// Corresponds to SwiftUI's `VerticalAlignment` type.
///
/// ## Usage
///
/// ```swift
/// HStack(alignment: .top) {
///     Text("Top aligned")
///     Text("Also top")
/// }
/// ```
///
/// - SeeAlso: `HStackSpec`, SwiftUI's `VerticalAlignment`
public enum VerticalAlignmentSpec: String, Codable, Equatable, Sendable {
    /// Aligns views to their top edge.
    case top
    
    /// Centers views vertically.
    case center
    
    /// Aligns views to their bottom edge.
    case bottom
    
    /// Aligns views to the first text baseline.
    ///
    /// For non-text views, falls back to `.top`.
    case firstTextBaseline
    
    /// Aligns views to the last text baseline.
    ///
    /// For non-text views, falls back to `.bottom`.
    case lastTextBaseline
}
