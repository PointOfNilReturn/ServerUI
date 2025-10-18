import Foundation

/// Manages state storage for server-side views.
///
/// `StateStore` maintains state per session, allowing views to have mutable state
/// that persists across requests and triggers re-renders when modified.
///
/// ## Usage
///
/// The state store is automatically managed by ServerUI. Access the current store via:
///
/// ```swift
/// StateStore.current.set("key", value: 42)
/// let value: Int = StateStore.current.get("key", default: 0)
/// ```
///
/// ## Session Management
///
/// Each client session has its own isolated state storage. State is:
/// - Created when the session starts
/// - Persists across multiple requests
/// - Cleaned up when the session expires
///
/// ## Thread Safety
///
/// StateStore is thread-safe and can be accessed from multiple concurrent requests.
///
/// - SeeAlso: `State`, `SessionContext`
public final class StateStore: @unchecked Sendable {
    /// The current state store for this execution context.
    ///
    /// Access this to get or set state values. The store is automatically scoped
    /// to the current session.
    nonisolated(unsafe) public static var current: StateStore = StateStore()
    
    /// The current navigation path for scoping state.
    ///
    /// State keys are prefixed with this path to ensure each view instance has
    /// independent state. When a view is popped from navigation, its state can be cleaned up.
    nonisolated(unsafe) public static var currentPath: String = "/"
    
    private var storage: [String: Any] = [:]
    private var defaults: [String: Any] = [:]
    private let lock = NSLock()
    
    /// Creates a new state store.
    public init() {}
    
    /// Registers a default value for a state key.
    ///
    /// This is called automatically when @State properties are initialized.
    ///
    /// - Parameters:
    ///   - key: The state key.
    ///   - value: The default value.
    public func registerDefault<Value>(_ key: String, value: Value) {
        lock.lock()
        defer { lock.unlock() }
        defaults[key] = value
    }
    
    /// Gets a value from the state store.
    ///
    /// - Parameters:
    ///   - key: The state key.
    ///   - defaultValue: The value to return if the key doesn't exist.
    /// - Returns: The stored value or the default.
    public func get<Value>(_ key: String, default defaultValue: Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        if let stored = storage[key] as? Value {
            return stored
        }
        if let defaultStored = defaults[key] as? Value {
            return defaultStored
        }
        return defaultValue
    }
    
    /// Sets a value in the state store.
    ///
    /// Setting a value marks the view as needing to be re-rendered.
    ///
    /// - Parameters:
    ///   - key: The state key.
    ///   - value: The value to store.
    public func set<Value>(_ key: String, value: Value) {
        lock.lock()
        defer { lock.unlock() }
        storage[key] = value
        // TODO: Trigger view update notification
    }
    
    /// Gets all current state as a dictionary.
    ///
    /// Used for session serialization and debugging.
    ///
    /// - Returns: Dictionary of all state values.
    public func getAllState() -> [String: Any] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }
    
    /// Restores state from a dictionary.
    ///
    /// Used when loading session state.
    ///
    /// - Parameter state: Dictionary of state values to restore.
    public func restoreState(_ state: [String: Any]) {
        lock.lock()
        defer { lock.unlock() }
        storage = state
    }
    
    /// Clears all state.
    ///
    /// Used when a session ends or for testing.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll()
        defaults.removeAll()
    }
    
    /// Clears state for a specific path.
    ///
    /// Used when a view is popped from navigation to clean up its state.
    ///
    /// - Parameter path: The navigation path whose state should be cleared.
    public func clearPath(_ path: String) {
        lock.lock()
        defer { lock.unlock() }
        
        let keysToRemove = storage.keys.filter { $0.hasPrefix("\(path)::") }
        for key in keysToRemove {
            storage.removeValue(forKey: key)
            defaults.removeValue(forKey: key)
        }
    }
}

/// Manages session state across multiple requests.
///
/// `SessionManager` associates each client session with its own `StateStore`,
/// allowing state to persist across HTTP requests.
///
/// ## Example
///
/// ```swift
/// // On incoming request
/// let sessionId = request.sessionId ?? UUID().uuidString
/// SessionManager.shared.activateSession(sessionId)
///
/// // State is now scoped to this session
/// let view = MyView()  // @State works correctly
/// let json = try ServerUIJSON.encode(view)
///
/// // Session state persists for next request
/// ```
///
/// - SeeAlso: `StateStore`, `State`
public final class SessionManager: @unchecked Sendable {
    /// The shared session manager instance.
    public static let shared = SessionManager()
    
    private var sessions: [String: StateStore] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    /// Activates a session, making it the current state store.
    ///
    /// - Parameter sessionId: The session identifier.
    /// - Returns: The state store for this session.
    @discardableResult
    public func activateSession(_ sessionId: String) -> StateStore {
        lock.lock()
        defer { lock.unlock() }
        
        let store: StateStore
        if let existing = sessions[sessionId] {
            store = existing
        } else {
            store = StateStore()
            sessions[sessionId] = store
        }
        StateStore.current = store
        return store
    }
    
    /// Gets the state store for a session without activating it.
    ///
    /// - Parameter sessionId: The session identifier.
    /// - Returns: The state store, or nil if the session doesn't exist.
    public func getSession(_ sessionId: String) -> StateStore? {
        lock.lock()
        defer { lock.unlock() }
        return sessions[sessionId]
    }
    
    /// Removes a session and its associated state.
    ///
    /// Call this when a session expires or the user logs out.
    ///
    /// - Parameter sessionId: The session identifier.
    public func removeSession(_ sessionId: String) {
        lock.lock()
        defer { lock.unlock() }
        sessions.removeValue(forKey: sessionId)
    }
    
    /// Removes all expired sessions.
    ///
    /// TODO: Implement session expiration based on last access time.
    public func cleanupExpiredSessions() {
        lock.lock()
        // TODO: Track last access time and remove old sessions
        lock.unlock()
    }
    
    /// Gets the number of active sessions.
    ///
    /// Useful for monitoring and debugging.
    public var sessionCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return sessions.count
    }
}

