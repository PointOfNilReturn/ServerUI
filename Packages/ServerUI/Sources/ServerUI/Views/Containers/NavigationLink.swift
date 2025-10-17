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
/// // Absolute path
/// NavigationLink("Profile", absolutePath: "/screen/profile")
///
/// // Relative path
/// NavigationLink("Settings", relativePath: "settings")
///
/// // With query parameters
/// NavigationLink("User", absolutePath: "/profile", query: ["id": "123"])
///
/// // Type-safe path builder
/// NavigationLink("Details", path: .relative("details"))
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
    /// Creates a navigation link with an absolute path.
    ///
    /// The destination is fetched from the server when the link is tapped.
    ///
    /// ## Example
    ///
    /// ```swift
    /// NavigationLink("Profile", absolutePath: "/screen/profile")
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - absolutePath: The absolute server path to fetch.
    init(_ title: String, absolutePath: String) {
        self.spec = .absolutePath(absolutePath)
        self.label = Text(verbatim: title)
        self.destination = EmptyView()
    }
    
    /// Creates a navigation link with a relative path.
    ///
    /// The path is resolved relative to the current screen's path.
    ///
    /// ## Example
    ///
    /// ```swift
    /// NavigationLink("Details", relativePath: "details")
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - relativePath: The relative server path to fetch.
    init(_ title: String, relativePath: String) {
        self.spec = .relativePath(relativePath)
        self.label = Text(verbatim: title)
        self.destination = EmptyView()
    }
    
    /// Creates a navigation link with an absolute path and query parameters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// NavigationLink("User Profile", absolutePath: "/profile", query: ["id": "123"])
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - absolutePath: The absolute server path to fetch.
    ///   - query: Query parameters to append to the path.
    init(_ title: String, absolutePath: String, query: [String: String]) {
        self.spec = .absolutePathWithQuery(path: absolutePath, query: query)
        self.label = Text(verbatim: title)
        self.destination = EmptyView()
    }
    
    /// Creates a navigation link with a relative path and query parameters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// NavigationLink("Details", relativePath: "details", query: ["tab": "info"])
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - relativePath: The relative server path to fetch.
    ///   - query: Query parameters to append to the path.
    init(_ title: String, relativePath: String, query: [String: String]) {
        self.spec = .relativePathWithQuery(path: relativePath, query: query)
        self.label = Text(verbatim: title)
        self.destination = EmptyView()
    }
    
    /// Creates a navigation link with a type-safe navigation path.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// NavigationLink("Details", path: .relative("details"))
    /// NavigationLink("Profile", path: .absolute("/profile"))
    /// NavigationLink("User", path: .absolute("/profile", query: ["id": "123"]))
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - path: A type-safe navigation path.
    init(_ title: String, path: NavigationPath) {
        self.spec = path.toSpec()
        self.label = Text(verbatim: title)
        self.destination = EmptyView()
    }
}

