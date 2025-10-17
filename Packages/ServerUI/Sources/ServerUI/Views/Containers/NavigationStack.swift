import ViewSchema

/// A view that provides stack-based navigation between views.
///
/// `NavigationStack` manages a navigation hierarchy where views can be pushed and popped.
/// Use `NavigationLink` within a navigation stack to navigate to new views.
///
/// ## Example
///
/// ```swift
/// NavigationStack {
///     VStack {
///         Text("Home Screen")
///             .font(.largeTitle)
///         
///         NavigationLink("Go to Details") {
///             DetailView()
///         }
///     }
///     .navigationTitle("Home")
/// }
/// ```
///
/// ## Client-Side State Management
///
/// NavigationStack's navigation state is managed on the client side. The server
/// defines the structure and available destinations, but the client handles the
/// actual navigation stack and back button behavior.
///
/// ## Platform Support
///
/// Requires iOS 16+ / macOS 13+. ServerUI targets iOS 17+ / macOS 14+ to ensure
/// full compatibility with modern SwiftUI navigation APIs.
///
/// - SeeAlso: `NavigationLink`, SwiftUI's `NavigationStack`
public struct NavigationStack<Content: View>: View, _NavigationStackProtocol {
    /// The specification for this navigation stack.
    public let spec: NavigationStackSpec
    
    /// The root content view displayed in the navigation stack.
    public let content: Content
    
    /// Creates a navigation stack with the given content.
    ///
    /// - Parameter content: A view builder that creates the root content.
    public init(@ViewBuilder content: () -> Content) {
        self.spec = NavigationStackSpec()
        self.content = content()
    }
    
    /// NavigationStack is a primitive container, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the specification and content for encoding.
    ///
    /// This method is used by the encoding engine to access NavigationStack's properties
    /// through protocol-based type erasure.
    ///
    /// - Returns: A tuple containing the NavigationStack specification and its type-erased content.
    public func extractNavigationStack() -> (spec: NavigationStackSpec, content: any View) {
        return (spec, content)
    }
}

