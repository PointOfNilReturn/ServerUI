/// The fundamental building block of ServerUI interfaces.
///
/// `View` is a protocol that represents a piece of UI that can be encoded into JSON
/// and sent to a client for rendering. It mirrors SwiftUI's `View` protocol, allowing
/// developers to use familiar declarative syntax on the server side.
///
/// ## Creating Custom Views
///
/// To create a custom view, conform to the `View` protocol and implement the `body` property:
///
/// ```swift
/// struct WelcomeView: View {
///     let userName: String
///
///     var body: some View {
///         VStack {
///             Text("Welcome!")
///                 .font(.largeTitle)
///             Text("Hello, \(userName)")
///                 .font(.body)
///         }
///     }
/// }
/// ```
///
/// ## View Composition
///
/// Views can be composed together to build complex interfaces. The `body` property
/// uses the `@ViewBuilder` result builder to enable declarative syntax with multiple
/// child views.
///
/// ## Encoding to JSON
///
/// Views are encoded into a `ViewHierarchy` JSON structure using the `ServerUIJSON.encode(_:)`
/// function. The encoding process recursively traverses the view tree and converts each
/// view into a `ViewNode` that can be serialized.
///
/// - Note: Leaf views (like `Text`) return `EmptyView` as their body to terminate recursion.
public protocol View {
    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required `body` property.
    associatedtype Body: View
    
    /// The content and behavior of the view.
    ///
    /// When you implement a custom view, you must implement a computed
    /// `body` property to provide the content for your view. Return a view
    /// that's composed of built-in views that ServerUI provides, plus other
    /// composite views that you've already defined.
    @ViewBuilder var body: Body { get }
}

/// A view that represents an empty space or a terminating node in the view tree.
///
/// `EmptyView` is used internally as the body of primitive views (like `Text`, `VStack`, `HStack`)
/// to signal that they are leaf nodes in the view hierarchy and should not be further decomposed.
///
/// You typically don't need to create `EmptyView` instances directly. The encoding engine
/// converts `EmptyView` to an "unknown" view type in the JSON output, which the client
/// interprets as having no visual representation.
///
/// ## Example
///
/// ```swift
/// public struct Text: View {
///     // Text is a primitive, so its body is EmptyView
///     public var body: EmptyView { EmptyView() }
/// }
/// ```
public struct EmptyView: View {
    public init() {}
    
    /// EmptyView's body is itself, terminating the view hierarchy recursion.
    public var body: EmptyView { self }
}
