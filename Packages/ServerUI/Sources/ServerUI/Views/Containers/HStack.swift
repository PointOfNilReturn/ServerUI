import ViewSchema

/// A view that arranges its children in a horizontal line.
///
/// `HStack` is a container view that lays out its child views from left to right (in left-to-right
/// locales). You can customize the alignment and spacing between children.
///
/// ## Example
///
/// ```swift
/// HStack(alignment: .top, spacing: 15) {
///     Text("Left")
///     Text("Center")
///     Text("Right")
/// }
/// ```
///
/// ## Unlimited Children with Parameter Packs
///
/// Unlike SwiftUI which limits stacks to 10 children, ServerUI's `HStack` supports
/// unlimited children thanks to Swift's parameter packs and the `@ViewBuilder`
/// implementation:
///
/// ```swift
/// HStack {
///     Text("Item 1")
///     Text("Item 2")
///     Text("Item 3")
///     // ... as many as you need!
/// }
/// ```
///
/// ## Alignment
///
/// The `alignment` parameter controls how children are aligned vertically:
/// - `.top` - Align to the top edge
/// - `.center` - Center vertically (default)
/// - `.bottom` - Align to the bottom edge
/// - `.firstTextBaseline` - Align to the first text baseline
/// - `.lastTextBaseline` - Align to the last text baseline
///
/// ## Spacing
///
/// The `spacing` parameter adds consistent horizontal space between children. If `nil`
/// (the default), the system uses platform-appropriate spacing.
///
/// - SeeAlso: `VStack`, `HStackSpec`
public struct HStack<Content: View>: View, _HStackProtocol {
    /// The specification defining alignment and spacing.
    public let spec: HStackSpec
    
    /// The content views arranged horizontally.
    public let content: Content
    
    /// Creates a horizontal stack with the given alignment and spacing.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the child views vertically. Defaults to `.center`.
    ///   - spacing: The distance between adjacent child views, or `nil` for default spacing.
    ///   - content: A view builder that creates the child views.
    public init(
        alignment: VerticalAlignmentSpec = .center,
        spacing: Double? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.spec = HStackSpec(alignment: alignment, spacing: spacing)
        self.content = content()
    }
    
    /// HStack is a primitive container, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the specification and content for encoding.
    ///
    /// This method is used by the encoding engine to access HStack's properties
    /// through protocol-based type erasure.
    ///
    /// - Returns: A tuple containing the HStack specification and its type-erased content.
    public func extractHStack() -> (spec: HStackSpec, content: any View) {
        return (spec, content)
    }
}

