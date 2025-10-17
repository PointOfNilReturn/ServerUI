import ViewSchema

/// A view that displays one or more lines of read-only text.
///
/// `Text` is a primitive view that renders textual content. It can be styled using
/// modifiers like `.font()` to adjust its appearance.
///
/// ## Example
///
/// ```swift
/// Text("Hello, World!")
///     .font(.largeTitle)
/// ```
///
/// ## Encoding
///
/// Text views are encoded as `ViewNode` instances with type `.text(TextSpec)`, where
/// the spec contains the string content. The client decodes these and renders them
/// using SwiftUI's native `Text` view.
///
/// ## Modifiers
///
/// Currently supported modifiers:
/// - `.font(_:)` - Sets the font style (largeTitle, title, headline, body, footnote, caption)
///
/// - SeeAlso: `TextSpec` for the schema definition
public struct Text: View {
    /// The specification defining the text content.
    public let spec: TextSpec

    /// Creates a text view that displays the given string.
    ///
    /// - Parameter string: The string to display.
    public init(_ string: String) {
        spec = .string(string)
    }
    
    /// Text is a primitive view, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
}
