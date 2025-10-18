import Foundation
import SwiftUI

/// Client-side cache for optimistic state updates.
///
/// This cache provides instant feedback for state changes before the server responds.
/// When a TextField changes, the value is stored here immediately so other views
/// can display it without waiting for the server round-trip.
///
/// ## Usage
///
/// ```swift
/// // TextField updates immediately:
/// cache.set(stateKey: "state_HomeScreen_7", value: "John")
///
/// // Text views check cache first:
/// let displayValue = cache.get(stateKey: "state_HomeScreen_7") ?? serverValue
/// ```
///
/// When the server responds with updated JSON, the cache entries are cleared
/// and the server becomes the source of truth again.
@Observable @MainActor
public final class OptimisticStateCache {
    /// Pending optimistic state updates.
    ///
    /// Keys are state keys (e.g., "state_HomeScreen_7")
    /// Values are the optimistically updated values
    private var cache: [String: String] = [:]
    
    /// Sets an optimistic value immediately.
    ///
    /// - Parameters:
    ///   - stateKey: The state key to update.
    ///   - value: The new optimistic value.
    public func set(stateKey: String, value: String) {
        cache[stateKey] = value
    }
    
    /// Gets an optimistic value if one exists.
    ///
    /// - Parameter stateKey: The state key to look up.
    /// - Returns: The optimistic value, or nil if none exists.
    public func get(stateKey: String) -> String? {
        return cache[stateKey]
    }
    
    /// Clears an optimistic value.
    ///
    /// Called when the server responds with updated state.
    ///
    /// - Parameter stateKey: The state key to clear.
    public func clear(stateKey: String) {
        cache.removeValue(forKey: stateKey)
    }
    
    /// Clears all optimistic values.
    ///
    /// Called when a full view update is received from the server.
    public func clearAll() {
        cache.removeAll()
    }
}

/// Environment key for optimistic state cache.
struct OptimisticStateCacheKey: EnvironmentKey {
    static let defaultValue: OptimisticStateCache? = nil
}

public extension EnvironmentValues {
    /// The optimistic state cache for the current view hierarchy.
    var optimisticStateCache: OptimisticStateCache? {
        get { self[OptimisticStateCacheKey.self] }
        set { self[OptimisticStateCacheKey.self] = newValue }
    }
}

