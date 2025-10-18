import Foundation

/// Enumeration of all supported view types in the ServerUI schema.
///
/// Each case corresponds to a specific view type and carries its associated specification.
/// New view types should be added as new cases to maintain forward compatibility.
///
/// - SeeAlso: `ViewNode`, `ViewHierarchy`
public enum ViewType: Codable, Sendable, Equatable, Hashable {
    /// Unknown view type - used for forward compatibility when client doesn't recognize a view.
    case unknown
    
    // MARK: - Primitives
    
    /// Text view with various initializer options.
    case text(TextSpec)
    
    /// Button view with action support.
    case button(ButtonSpec)
    
    /// Text field view with binding support.
    case textField(TextFieldSpec)
    
    // MARK: - Layout Containers
    
    /// Vertical stack layout container.
    case vstack(VStackSpec)
    
    /// Horizontal stack layout container.
    case hstack(HStackSpec)
    
    /// List container for displaying collections.
    case list(ListSpec)
    
    /// Scroll view container for scrollable content.
    case scrollView(ScrollViewSpec)
    
    // MARK: - Navigation
    
    /// Navigation stack container for hierarchical navigation.
    case navigationStack(NavigationStackSpec)
    
    /// Navigation link that navigates to a destination view.
    case navigationLink(NavigationLinkSpec)
}
