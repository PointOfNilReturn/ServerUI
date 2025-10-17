import SwiftUI

/// Environment key for accessing the path navigator.
struct PathNavigatorKey: EnvironmentKey {
    static let defaultValue: PathNavigator? = nil
}

public extension EnvironmentValues {
    /// The path navigator for fetching server-driven navigation destinations.
    var pathNavigator: PathNavigator? {
        get { self[PathNavigatorKey.self] }
        set { self[PathNavigatorKey.self] = newValue }
    }
}

