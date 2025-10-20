import SwiftUI
import ViewSchema
import Logging

/// A reactive cache for UI state that bridges server state with instant client updates.
///
/// The ReactiveStateCache is initialized with state values from the server and provides
/// instant read/write access for UI components. Changes are automatically debounced and
/// synced back to the server in the background.
///
/// ## Architecture
///
/// ```
/// Server → initialState → ReactiveStateCache → Views (instant!)
///                              ↓
///                         Server (debounced sync)
/// ```
///
/// ## Usage
///
/// ```swift
/// // Initialize cache when view hierarchy loads
/// cache.initialize(hierarchy.initialState)
///
/// // Views bind to cache (instant reads/writes!)
/// TextField("Name", text: cache.binding(for: stateKey))
/// ```
///
/// - SeeAlso: `ViewHierarchy`, `StateUpdater`
@Observable @MainActor
public final class ReactiveStateCache {
    /// The underlying storage for state values.
    private var storage: [String: Any] = [:]
    
    /// Keys that have pending updates to the server.
    ///
    /// When the cache has local changes that haven't been confirmed by the server yet,
    /// we track them here to prevent server responses from overwriting newer local values.
    private var pendingUpdates: Set<String> = []
    
    /// State updater for syncing changes to the server.
    private weak var stateUpdater: StateUpdater?
    
    private let logger = Logger(label: "com.serverui.reactivecache")
    
    public init() {}
    
    /// Initializes the cache with state from the server.
    ///
    /// This should be called when a new view hierarchy is loaded.
    /// It updates cached values with the server's current state, but preserves
    /// any values that have pending local updates to avoid race conditions.
    ///
    /// - Parameter initialState: State dictionary from `ViewHierarchy`
    public func initialize(_ initialState: [String: StateValue]) {
        logger.debug("Initializing cache with \(initialState.count) state values (pending: \(pendingUpdates.count))")
        
        // Load initial values, but skip keys with pending updates
        var skippedCount = 0
        for (key, value) in initialState {
            if pendingUpdates.contains(key) {
                // Don't overwrite - user has made local changes that are newer
                skippedCount += 1
                logger.trace("Skipped overwriting pending key", metadata: ["key": "\(key)"])
                continue
            }
            
            if let anyValue = value.anyValue {
                storage[key] = anyValue
                logger.trace("Loaded initial state", metadata: ["key": "\(key)", "value": "\(anyValue)"])
            }
        }
        
        if skippedCount > 0 {
            logger.debug("Skipped \(skippedCount) keys with pending updates")
        }
    }
    
    /// Sets the state updater for server synchronization.
    ///
    /// - Parameter updater: The state updater to use for syncing changes
    public func setStateUpdater(_ updater: StateUpdater) {
        self.stateUpdater = updater
    }
    
    /// Gets a value from the cache.
    ///
    /// - Parameter key: The state key
    /// - Returns: The cached value, or nil if not found
    public func get<T>(_ key: String) -> T? {
        return storage[key] as? T
    }
    
    /// Sets a value in the cache and syncs to server.
    ///
    /// The value is stored immediately (instant UI update) and marked as pending.
    /// It's then sent to the server with debouncing. Pending keys won't be overwritten
    /// by server responses until confirmed.
    ///
    /// - Parameters:
    ///   - key: The state key
    ///   - value: The new value
    public func set<T>(_ key: String, value: T) {
        // Update cache immediately (instant UI)
        storage[key] = value
        pendingUpdates.insert(key)
        logger.trace("Cache updated (pending)", metadata: ["key": "\(key)", "value": "\(value)"])
        
        // Sync to server (debounced)
        if let stateUpdater = stateUpdater {
            let stringValue = String(describing: value)
            stateUpdater.updateState(key, value: stringValue)
        } else {
            logger.warning("No state updater configured - changes won't sync to server")
        }
    }
    
    /// Confirms that a state update has been processed by the server.
    ///
    /// This removes the key from pending updates, allowing future server responses
    /// to update the cache for this key.
    ///
    /// - Parameter key: The state key that was confirmed
    public func confirmUpdate(_ key: String) {
        if pendingUpdates.remove(key) != nil {
            logger.trace("Confirmed server update", metadata: ["key": "\(key)"])
        }
    }
    
    /// Creates a binding to a cached value.
    ///
    /// The binding provides instant read/write access to the cache,
    /// with automatic server synchronization on writes.
    ///
    /// - Parameter key: The state key
    /// - Returns: A binding to the cached value
    public func binding(for key: String) -> Binding<String> {
        return Binding(
            get: { [weak self] in
                self?.get(key) ?? ""
            },
            set: { [weak self] newValue in
                self?.set(key, value: newValue)
            }
        )
    }
    
    /// Merges new state values from the server.
    ///
    /// This updates the cache with fresh values from the server, but only for keys
    /// that aren't currently pending (i.e., not in the middle of being updated by the user).
    ///
    /// - Parameter initialState: The state dictionary from the server
    public func mergeServerState(_ initialState: [String: ViewSchema.StateValue]) {
        for (key, stateValue) in initialState {
            // Skip keys that are pending user updates
            guard !pendingUpdates.contains(key) else {
                logger.trace("Skipping pending key during server merge", metadata: ["key": "\(key)"])
                continue
            }
            
            // Update cache with server's value
            if let value = stateValue.anyValue {
                storage[key] = value
                logger.trace("Merged server state", metadata: ["key": "\(key)", "value": "\(value)"])
            }
        }
    }
    
    /// Clears all cached values.
    ///
    /// This is typically called when navigating away from a view.
    public func clearAll() {
        logger.debug("Clearing all cached state")
        storage.removeAll()
        pendingUpdates.removeAll()
    }
}

// MARK: - Environment Key

struct ReactiveStateCacheKey: EnvironmentKey {
    static let defaultValue: ReactiveStateCache? = nil
}

extension EnvironmentValues {
    var reactiveStateCache: ReactiveStateCache? {
        get { self[ReactiveStateCacheKey.self] }
        set { self[ReactiveStateCacheKey.self] = newValue }
    }
}

