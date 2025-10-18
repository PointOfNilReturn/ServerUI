import ViewSchema

/// A container that presents rows of data arranged in a single column.
///
/// `List` provides a scrollable list of views, similar to SwiftUI's List.
/// Each child view becomes a row in the list.
///
/// ## Example
///
/// ```swift
/// List {
///     Text("Item 1")
///     Text("Item 2")
///     Text("Item 3")
/// }
/// ```
///
/// ## With Navigation
///
/// Lists commonly contain NavigationLinks:
///
/// ```swift
/// List {
///     NavigationLink("Profile") {
///         ProfileView()
///     }
///     NavigationLink("Settings") {
///         SettingsView()
///     }
/// }
/// ```
///
/// ## Encoding
///
/// List encodes its children as an array of ViewNodes. The client
/// renders each child as a row in a native list view.
///
/// - SeeAlso: `ScrollView`, `VStack`
public struct List<Content: View>: View, _ListProtocol {
    /// The list's content.
    public let content: Content
    
    /// Creates a list with the given content.
    ///
    /// - Parameter content: A view builder that creates the list's rows.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    /// List is a container, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the list's content for encoding.
    ///
    /// This method is used by the encoding engine to access the list's content
    /// through protocol-based type erasure.
    ///
    /// - Returns: The type-erased content view.
    public func extractList() -> (spec: ListSpec, content: any View) {
        return (ListSpec(), content)
    }
}

