import ViewSchema

/// A view that navigates to a destination view when tapped.
///
/// `NavigationLink` creates a button-like element that triggers navigation when activated.
/// It must be used within a `NavigationStack` to function properly.
///
/// ## Embedded Navigation (SwiftUI-mirroring)
///
/// The destination view is encoded directly in the JSON:
///
/// ```swift
/// NavigationLink("Details") {
///     DetailView()  // Encoded immediately
///         .navigationTitle("Details")
/// }
/// ```
///
/// ## Path-Based Navigation (On-Demand)
///
/// The destination is fetched lazily when the link is tapped:
///
/// ```swift
/// NavigationLink("Profile", path: "/screen/profile")
/// NavigationLink("User", path: "/profile", query: ["id": "123"])
/// NavigationLink("Settings", path: .path("/settings"))
/// ```
///
/// ## Encoding
///
/// - **Embedded**: Two child nodes (label + destination)
/// - **Path-based**: One child node (label only), path in spec
///
/// - SeeAlso: `NavigationStack`, `NavigationPath`, SwiftUI's `NavigationLink`
public struct NavigationLink<Label: View, Destination: View>: View, _NavigationLinkProtocol {
    /// The specification for this navigation link.
    public let spec: NavigationLinkSpec
    
    /// The label view displayed in the current screen.
    public let label: Label
    
    /// The destination view navigated to when the link is tapped.
    public let destination: Destination
    
    /// Creates a navigation link with an embedded destination.
    ///
    /// The destination view is encoded in the JSON and included in the initial payload.
    ///
    /// - Parameters:
    ///   - label: A view builder that creates the label.
    ///   - destination: A view builder that creates the destination view.
    public init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder destination: () -> Destination
    ) {
        self.spec = .embedded
        self.label = label()
        self.destination = destination()
    }
    
    /// NavigationLink is a primitive, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the specification, label, and destination for encoding.
    ///
    /// This method is used by the encoding engine to access NavigationLink's properties
    /// through protocol-based type erasure.
    ///
    /// - Returns: A tuple containing the spec, label view, and destination view (all type-erased).
    public func extractNavigationLink() -> (spec: NavigationLinkSpec, label: any View, destination: any View) {
        return (spec, label, destination)
    }
}

// MARK: - Convenience Initializers

public extension NavigationLink where Label == Text {
    /// Creates a navigation link with a text label and embedded destination.
    ///
    /// This is a convenience initializer for the common case of a simple text label.
    ///
    /// ## Example
    ///
    /// ```swift
    /// NavigationLink("Settings") {
    ///     SettingsView()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - destination: A view builder that creates the destination view.
    init(_ title: String, @ViewBuilder destination: () -> Destination) {
        self.spec = .embedded
        self.label = Text(verbatim: title)
        self.destination = destination()
    }
}

// MARK: - Path-Based Navigation

public extension NavigationLink where Label == Text, Destination == EmptyView {
    /// Creates a navigation link with a path.
    ///
    /// The destination is fetched from the server when the link is tapped.
    ///
    /// ## Example
    ///
    /// ```swift
    /// NavigationLink("Profile", path: "/screen/profile")
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - path: The server path to fetch.
    init(_ title: String, path: String) {
        self.spec = .path(path)
        self.label = Text(verbatim: title)
        self.destination = EmptyView()
    }
    
    /// Creates a navigation link with a path and query parameters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// NavigationLink("User Profile", path: "/profile", query: ["id": "123"])
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - path: The server path to fetch.
    ///   - query: Query parameters to append to the path.
    init(_ title: String, path: String, query: [String: String]) {
        self.spec = .pathWithQuery(path: path, query: query)
        self.label = Text(verbatim: title)
        self.destination = EmptyView()
    }
    
    /// Creates a navigation link with a type-safe navigation path.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// NavigationLink("Profile", path: .path("/profile"))
    /// NavigationLink("User", path: .pathWithQuery("/profile", query: ["id": "123"]))
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - typeSafePath: A type-safe navigation path.
    init(_ title: String, path typeSafePath: NavigationPath) {
        self.spec = typeSafePath.toSpec()
        self.label = Text(verbatim: title)
        self.destination = EmptyView()
    }
}

