import SwiftUI
import ViewSchema

/// A wrapper to make NavigationPath injectable into the environment.
@Observable
@MainActor
public final class NavigationPathHolder {
    public var path: [ViewHierarchy] = []
    
    public init() {}
    
    public func append(_ hierarchy: ViewHierarchy) {
        path.append(hierarchy)
    }
    
    public func removeLast() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Updates the most recent (top) destination in the navigation stack.
    ///
    /// This is used when an action is performed in a nested view and we need to
    /// update that view without resetting the navigation stack.
    ///
    /// - Parameter hierarchy: The updated view hierarchy for the current destination.
    public func updateCurrent(_ hierarchy: ViewHierarchy) {
        guard !path.isEmpty else { return }
        path[path.count - 1] = hierarchy
    }
}

/// Environment key for accessing the navigation path holder.
struct NavigationPathKey: EnvironmentKey {
    static let defaultValue: NavigationPathHolder? = nil
}

public extension EnvironmentValues {
    /// The navigation path holder for programmatic navigation.
    var navigationPath: NavigationPathHolder? {
        get { self[NavigationPathKey.self] }
        set { self[NavigationPathKey.self] = newValue }
    }
}

