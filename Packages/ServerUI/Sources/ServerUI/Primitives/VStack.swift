import ViewSchema

/// A view that arranges its children in a vertical line.
///
/// `VStack` is a container view that lays out its child views from top to bottom.
/// You can customize the alignment and spacing between children.
///
/// ## Example
///
/// ```swift
/// VStack(alignment: .leading, spacing: 10) {
///     Text("Title")
///         .font(.headline)
///     Text("Subtitle")
///         .font(.body)
///     Text("Description")
///         .font(.caption)
/// }
/// ```
///
/// ## Unlimited Children with Parameter Packs
///
/// Unlike SwiftUI which limits stacks to 10 children, ServerUI's `VStack` supports
/// unlimited children thanks to Swift's parameter packs and the `@ViewBuilder`
/// implementation:
///
/// ```swift
/// VStack {
///     Text("Child 1")
///     Text("Child 2")
///     Text("Child 3")
///     // ... as many as you need!
/// }
/// ```
///
/// ## Alignment
///
/// The `alignment` parameter controls how children are aligned horizontally:
/// - `.leading` - Align to the left edge
/// - `.center` - Center horizontally (default)
/// - `.trailing` - Align to the right edge
///
/// ## Spacing
///
/// The `spacing` parameter adds consistent vertical space between children. If `nil`
/// (the default), the system uses platform-appropriate spacing.
///
/// - SeeAlso: `HStack`, `VStackSpec`
public struct VStack<Content: View>: View, _VStackProtocol {
    /// The specification defining alignment and spacing.
    public let spec: VStackSpec
    
    /// The content views arranged vertically.
    public let content: Content
    
    /// Creates a vertical stack with the given alignment and spacing.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the child views horizontally. Defaults to `.center`.
    ///   - spacing: The distance between adjacent child views, or `nil` for default spacing.
    ///   - content: A view builder that creates the child views.
    public init(
        alignment: HorizontalAlignmentSpec = .center,
        spacing: Double? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.spec = VStackSpec(alignment: alignment, spacing: spacing)
        self.content = content()
    }
    
    /// VStack is a primitive container, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the specification and content for encoding.
    ///
    /// This method is used by the encoding engine to access VStack's properties
    /// through protocol-based type erasure.
    ///
    /// - Returns: A tuple containing the VStack specification and its type-erased content.
    public func extractVStack() -> (spec: VStackSpec, content: any View) {
        return (spec, content)
    }
}

