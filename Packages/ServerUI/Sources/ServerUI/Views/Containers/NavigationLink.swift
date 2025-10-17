import ViewSchema

/// A view that navigates to a destination view when tapped.
///
/// `NavigationLink` creates a button-like element that triggers navigation when activated.
/// It must be used within a `NavigationStack` to function properly.
///
/// ## Example
///
/// ```swift
/// NavigationStack {
///     VStack {
///         NavigationLink {
///             Text("Tap to Navigate")
///                 .font(.headline)
///         } destination: {
///             Text("Destination View")
///                 .navigationTitle("Details")
///         }
///     }
/// }
/// ```
///
/// ## Convenience Initializers
///
/// For simple text labels, use the string-based initializer:
///
/// ```swift
/// NavigationLink("Go to Settings") {
///     SettingsView()
/// }
/// ```
///
/// ## Encoding
///
/// The label and destination are encoded as two separate child ViewNodes:
/// - First child: the label view (what's displayed)
/// - Second child: the destination view (where navigation goes)
///
/// The client renderer knows to interpret these children appropriately when
/// rendering the NavigationLink.
///
/// - SeeAlso: `NavigationStack`, SwiftUI's `NavigationLink`
public struct NavigationLink<Label: View, Destination: View>: View, _NavigationLinkProtocol {
    /// The specification for this navigation link.
    public let spec: NavigationLinkSpec
    
    /// The label view displayed in the current screen.
    public let label: Label
    
    /// The destination view navigated to when the link is tapped.
    public let destination: Destination
    
    /// Creates a navigation link with a label and destination.
    ///
    /// - Parameters:
    ///   - label: A view builder that creates the label.
    ///   - destination: A view builder that creates the destination view.
    public init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder destination: () -> Destination
    ) {
        self.spec = NavigationLinkSpec()
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
    /// Creates a navigation link with a text label.
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
        self.spec = NavigationLinkSpec()
        self.label = Text(verbatim: title)
        self.destination = destination()
    }
}

