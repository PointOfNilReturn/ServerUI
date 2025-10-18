import ViewSchema

/// A scrollable view.
///
/// `ScrollView` provides a container that allows scrolling through content
/// that might not fit on screen.
///
/// ## Example
///
/// ```swift
/// ScrollView {
///     VStack {
///         ForEach(0..<100) { i in
///             Text("Row \(i)")
///         }
///     }
/// }
/// ```
///
/// ## Horizontal Scrolling
///
/// ```swift
/// ScrollView(.horizontal) {
///     HStack {
///         ForEach(items) { item in
///             ItemCard(item)
///         }
///     }
/// }
/// ```
///
/// ## Both Axes
///
/// ```swift
/// ScrollView(.both) {
///     // Large content that scrolls in both directions
///     Image("largeMap")
/// }
/// ```
///
/// - SeeAlso: `List`, `VStack`, `HStack`
public struct ScrollView<Content: View>: View, _ScrollViewProtocol {
    /// The scroll view's content.
    public let content: Content
    
    /// The axes specification.
    private let spec: ScrollViewSpec
    
    /// Creates a scroll view with the given axes.
    ///
    /// - Parameters:
    ///   - axes: The scroll axes (.vertical by default).
    ///   - content: A view builder that creates the scrollable content.
    public init(_ axes: ScrollAxes = .vertical, @ViewBuilder content: () -> Content) {
        self.spec = ScrollViewSpec(axes: axes)
        self.content = content()
    }
    
    /// ScrollView is a container, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the scroll view's spec and content for encoding.
    ///
    /// This method is used by the encoding engine to access the scroll view's properties
    /// through protocol-based type erasure.
    ///
    /// - Returns: A tuple containing the spec and type-erased content.
    public func extractScrollView() -> (spec: ScrollViewSpec, content: any View) {
        return (spec, content)
    }
}

