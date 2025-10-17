import Foundation

/// View modifiers that can be applied to any view.
///
/// Modifiers are encoded as part of the view node and applied by the client renderer.
///
/// - SeeAlso: `ViewNode`, `ModifiedContent`
public enum Modifier: Codable, Equatable, Sendable, Hashable {
    /// Applies a semantic font style to text content.
    case font(FontRole)
    
    /// Adds padding around a view.
    case padding(PaddingSpec)
    
    /// Sets the frame dimensions of a view.
    case frame(FrameSpec)
    
    /// Sets the navigation title for a view within a navigation stack.
    case navigationTitle(String)
}

/// Semantic font roles that map to platform-appropriate text styles.
///
/// These font roles automatically adapt to user settings like Dynamic Type on iOS.
///
/// - SeeAlso: SwiftUI's `Font` type
public enum FontRole: String, Codable, Equatable, Sendable {
    case largeTitle, title, headline, body, footnote, caption
}

/// Specification for padding around a view.
///
/// Corresponds to SwiftUI's `.padding()` modifier variants.
public enum PaddingSpec: Codable, Equatable, Sendable, Hashable {
    /// Default padding on all edges (typically 16 points on iOS).
    case all
    
    /// Specific amount of padding on all edges.
    case amount(Double)
    
    /// Specific edges with optional custom amount.
    ///
    /// If amount is `nil`, uses default padding for those edges.
    case edges(EdgeSetSpec, amount: Double?)
}

/// Specification for view frame dimensions.
///
/// Corresponds to SwiftUI's `.frame()` modifier variants.
public enum FrameSpec: Codable, Equatable, Sendable, Hashable {
    /// Fixed frame with optional width and height.
    ///
    /// - Parameters:
    ///   - width: Fixed width in points (nil means no constraint)
    ///   - height: Fixed height in points (nil means no constraint)
    ///   - alignment: How to align the view within the frame
    case fixed(width: Double?, height: Double?, alignment: AlignmentSpec?)
    
    /// Flexible frame with min, ideal, and max constraints.
    ///
    /// - Parameters:
    ///   - minWidth: Minimum width in points
    ///   - idealWidth: Ideal width in points
    ///   - maxWidth: Maximum width in points
    ///   - minHeight: Minimum height in points
    ///   - idealHeight: Ideal height in points
    ///   - maxHeight: Maximum height in points
    ///   - alignment: How to align the view within the frame
    case flexible(
        minWidth: Double?,
        idealWidth: Double?,
        maxWidth: Double?,
        minHeight: Double?,
        idealHeight: Double?,
        maxHeight: Double?,
        alignment: AlignmentSpec?
    )
}

/// Edge sets for specifying which edges to apply modifiers to.
///
/// Corresponds to SwiftUI's `Edge.Set` type.
public enum EdgeSetSpec: String, Codable, Equatable, Sendable {
    /// All four edges.
    case all
    
    /// The top edge.
    case top
    
    /// The bottom edge.
    case bottom
    
    /// The leading edge (left in LTR, right in RTL).
    case leading
    
    /// The trailing edge (right in LTR, left in RTL).
    case trailing
    
    /// The left and right edges (horizontal).
    case horizontal
    
    /// The top and bottom edges (vertical).
    case vertical
}

/// 2D alignment specification.
///
/// Combines horizontal and vertical alignment for frame positioning.
///
/// Corresponds to SwiftUI's `Alignment` type.
public enum AlignmentSpec: String, Codable, Equatable, Sendable {
    case topLeading, top, topTrailing
    case leading, center, trailing
    case bottomLeading, bottom, bottomTrailing
}
