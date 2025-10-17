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
}

