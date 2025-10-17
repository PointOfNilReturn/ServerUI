/// Specification for a vertical stack container.
///
/// VStack arranges its children vertically from top to bottom.
///
/// Corresponds to SwiftUI's `VStack` type.
///
/// ## Properties
///
/// - `alignment`: Horizontal alignment for child views (defaults to `.center`)
/// - `spacing`: Custom spacing between child views in points (defaults to system-defined spacing if `nil`)
///
/// ## JSON Encoding
///
/// ```json
/// {
///   "type": {
///     "vstack": {
///       "alignment": "leading",
///       "spacing": 20
///     }
///   }
/// }
/// ```
///
/// ## Usage
///
/// ```swift
/// VStack(alignment: .leading, spacing: 12) {
///     Text("First item")
///     Text("Second item")
///     Text("Third item")
/// }
/// ```
///
/// - SeeAlso: `HStackSpec`, `HorizontalAlignmentSpec`, SwiftUI's `VStack`
public struct VStackSpec: Codable, Equatable, Sendable, Hashable {
    /// The horizontal alignment for child views within the stack.
    ///
    /// When `nil`, defaults to `.center`.
    public let alignment: HorizontalAlignmentSpec?
    
    /// The custom spacing between child views in points.
    ///
    /// When `nil`, uses the system-defined spacing.
    public let spacing: Double?
    
    /// Creates a VStack specification with the given alignment and spacing.
    ///
    /// - Parameters:
    ///   - alignment: The horizontal alignment (defaults to `nil`, which means `.center`)
    ///   - spacing: The spacing between children in points (defaults to `nil` for system spacing)
    public init(alignment: HorizontalAlignmentSpec? = nil, spacing: Double? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }
}
