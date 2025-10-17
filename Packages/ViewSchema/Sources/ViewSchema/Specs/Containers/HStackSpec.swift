/// Specification for a horizontal stack container.
///
/// HStack arranges its children horizontally from leading to trailing.
///
/// Corresponds to SwiftUI's `HStack` type.
///
/// ## Properties
///
/// - `alignment`: Vertical alignment for child views (defaults to `.center`)
/// - `spacing`: Custom spacing between child views in points (defaults to system-defined spacing if `nil`)
///
/// ## JSON Encoding
///
/// ```json
/// {
///   "type": {
///     "hstack": {
///       "alignment": "top",
///       "spacing": 16
///     }
///   }
/// }
/// ```
///
/// ## Usage
///
/// ```swift
/// HStack(alignment: .top, spacing: 8) {
///     Text("First item")
///     Text("Second item")
///     Text("Third item")
/// }
/// ```
///
/// - SeeAlso: `VStackSpec`, `VerticalAlignmentSpec`, SwiftUI's `HStack`
public struct HStackSpec: Codable, Equatable, Sendable, Hashable {
    /// The vertical alignment for child views within the stack.
    ///
    /// When `nil`, defaults to `.center`.
    public let alignment: VerticalAlignmentSpec?
    
    /// The custom spacing between child views in points.
    ///
    /// When `nil`, uses the system-defined spacing.
    public let spacing: Double?
    
    /// Creates an HStack specification with the given alignment and spacing.
    ///
    /// - Parameters:
    ///   - alignment: The vertical alignment (defaults to `nil`, which means `.center`)
    ///   - spacing: The spacing between children in points (defaults to `nil` for system spacing)
    public init(alignment: VerticalAlignmentSpec? = nil, spacing: Double? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }
}
