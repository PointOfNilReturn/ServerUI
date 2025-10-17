import ViewSchema

// MARK: - Modified View

/// A wrapper view that applies a modifier to another view.
///
/// `ModifiedContent` is created automatically when you call a modifier method on a view.
/// It wraps the original view along with the modifier specification, which is later
/// encoded into the JSON representation.
///
/// ## Modifier Chaining
///
/// Modifiers can be chained, creating a nested structure:
///
/// ```swift
/// Text("Hello")
///     .font(.largeTitle)
///     .foregroundColor(.blue)  // Future modifier
/// // Creates: ModifiedContent<ModifiedContent<Text>>
/// ```
///
/// During encoding, the engine recursively unwraps `ModifiedContent` layers and
/// accumulates all modifiers into an array on the resulting `ViewNode`.
///
/// ## Encoding Process
///
/// 1. The encoding engine detects `ModifiedContent` via `ModifiedContentProtocol`
/// 2. It extracts the modifier and inner content
/// 3. It recursively encodes the inner content
/// 4. It appends the modifier to the node's `modifiers` array
/// 5. The client applies modifiers in order when rendering
///
/// - Note: This is an implementation detail. Users create `ModifiedContent` instances
///   by calling modifier methods, not by constructing them directly.
public struct ModifiedContent<Content: View>: View, _ModifiedContentProtocol {
    /// The underlying view being modified.
    let content: Content
    
    /// The modifier to apply.
    let modifier: Modifier
    
    /// Creates a modified content view.
    ///
    /// - Parameters:
    ///   - content: The view to modify.
    ///   - modifier: The modifier to apply.
    init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
    
    /// Modified content is a wrapper, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the modifier and underlying content for encoding.
    ///
    /// The encoding engine uses this method to access the wrapped content and modifier
    /// through protocol-based type erasure.
    ///
    /// - Returns: A tuple containing the type-erased content view and the modifier.
    public func extractModifier() -> (content: any View, modifier: Modifier) {
        return (content, modifier)
    }
}

// MARK: - View Extensions for Modifiers

public extension View {
    /// Sets the font style for text in this view.
    ///
    /// Use this modifier to adjust the size and weight of text. The font roles map to
    /// standard system font sizes that adapt across platforms and accessibility settings.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Text("Welcome")
    ///     .font(.largeTitle)
    /// ```
    ///
    /// ## Available Font Roles
    ///
    /// - `.largeTitle` - The largest title font
    /// - `.title` - A prominent title font
    /// - `.headline` - A bold font for headings
    /// - `.body` - The default body text font (most common)
    /// - `.footnote` - Small supplementary text
    /// - `.caption` - The smallest text size
    ///
    /// - Parameter role: The font role to apply.
    /// - Returns: A view with the font modifier applied.
    func font(_ role: FontRole) -> ModifiedContent<Self> {
        ModifiedContent(content: self, modifier: .font(role))
    }
    
    // MARK: - Padding Modifiers
    
    /// Adds default padding around all edges of this view.
    ///
    /// The default padding amount is platform-specific (typically 16 points on iOS).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Text("Hello")
    ///     .padding()
    /// ```
    ///
    /// - Returns: A view with default padding on all edges.
    func padding() -> ModifiedContent<Self> {
        ModifiedContent(content: self, modifier: .padding(.all))
    }
    
    /// Adds specific amount of padding around all edges of this view.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Text("Hello")
    ///     .padding(20)
    /// ```
    ///
    /// - Parameter amount: The amount of padding in points.
    /// - Returns: A view with the specified padding on all edges.
    func padding(_ amount: Double) -> ModifiedContent<Self> {
        ModifiedContent(content: self, modifier: .padding(.amount(amount)))
    }
    
    /// Adds padding to specific edges of this view.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Default padding on horizontal edges
    /// Text("Hello")
    ///     .padding(.horizontal)
    ///
    /// // Custom padding on top edge only
    /// Text("Hello")
    ///     .padding(.top, 30)
    /// ```
    ///
    /// - Parameters:
    ///   - edges: The edges to add padding to.
    ///   - amount: The amount of padding in points. If `nil`, uses default padding.
    /// - Returns: A view with padding on the specified edges.
    func padding(_ edges: EdgeSetSpec, _ amount: Double? = nil) -> ModifiedContent<Self> {
        ModifiedContent(content: self, modifier: .padding(.edges(edges, amount: amount)))
    }
    
    // MARK: - Frame Modifiers
    
    /// Sets a fixed frame for this view with optional width and height.
    ///
    /// Use this modifier to set exact dimensions or constrain only one dimension.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Fixed square
    /// Text("Hello")
    ///     .frame(width: 100, height: 100)
    ///
    /// // Fixed width, flexible height
    /// Text("Long text that will wrap")
    ///     .frame(width: 200)
    ///
    /// // Fixed width with alignment
    /// Text("Hello")
    ///     .frame(width: 200, height: 100, alignment: .topLeading)
    /// ```
    ///
    /// - Parameters:
    ///   - width: The fixed width in points. If `nil`, width is flexible.
    ///   - height: The fixed height in points. If `nil`, height is flexible.
    ///   - alignment: The alignment within the frame. Defaults to `.center`.
    /// - Returns: A view with the specified frame.
    func frame(
        width: Double? = nil,
        height: Double? = nil,
        alignment: AlignmentSpec = .center
    ) -> ModifiedContent<Self> {
        ModifiedContent(content: self, modifier: .frame(.fixed(
            width: width,
            height: height,
            alignment: alignment
        )))
    }
    
    /// Sets a flexible frame for this view with min, ideal, and max constraints.
    ///
    /// Use this modifier when you want your view to grow and shrink within constraints.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Minimum width, but can grow
    /// Text("Dynamic width")
    ///     .frame(minWidth: 100)
    ///
    /// // Constrained between min and max
    /// Text("Flexible")
    ///     .frame(minWidth: 100, maxWidth: 300, minHeight: 50, maxHeight: 200)
    ///
    /// // Ideal size with alignment
    /// Text("Centered")
    ///     .frame(idealWidth: 200, idealHeight: 100, alignment: .center)
    /// ```
    ///
    /// - Parameters:
    ///   - minWidth: The minimum width in points.
    ///   - idealWidth: The ideal width in points.
    ///   - maxWidth: The maximum width in points.
    ///   - minHeight: The minimum height in points.
    ///   - idealHeight: The ideal height in points.
    ///   - maxHeight: The maximum height in points.
    ///   - alignment: The alignment within the frame. Defaults to `.center`.
    /// - Returns: A view with the specified flexible frame.
    func frame(
        minWidth: Double? = nil,
        idealWidth: Double? = nil,
        maxWidth: Double? = nil,
        minHeight: Double? = nil,
        idealHeight: Double? = nil,
        maxHeight: Double? = nil,
        alignment: AlignmentSpec = .center
    ) -> ModifiedContent<Self> {
        ModifiedContent(content: self, modifier: .frame(.flexible(
            minWidth: minWidth,
            idealWidth: idealWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            idealHeight: idealHeight,
            maxHeight: maxHeight,
            alignment: alignment
        )))
    }
}

