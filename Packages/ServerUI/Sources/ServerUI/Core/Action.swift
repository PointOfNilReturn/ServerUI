import Foundation

/// A unique identifier for an action.
public typealias ActionID = String

/// Represents an action that can be executed on the server.
///
/// Actions are created when users interact with UI elements like buttons.
/// The client sends the action ID back to the server, which executes the
/// associated closure.
public struct Action: Sendable {
    /// The unique identifier for this action.
    public let id: ActionID
    
    /// The action to execute.
    ///
    /// This closure is called when the client sends this action ID.
    /// It should mutate @State or perform other side effects.
    let execute: @Sendable () -> Void
    
    /// Creates an action with a unique ID.
    ///
    /// - Parameter execute: The closure to execute when this action is triggered.
    public init(execute: @escaping @Sendable () -> Void) {
        self.id = "action_\(UUID().uuidString)"
        self.execute = execute
    }
    
    /// Creates an action with a specific ID.
    ///
    /// Used internally for action restoration.
    ///
    /// - Parameters:
    ///   - id: The action identifier.
    ///   - execute: The closure to execute.
    init(id: ActionID, execute: @escaping @Sendable () -> Void) {
        self.id = id
        self.execute = execute
    }
}

/// Registry for storing and executing actions.
///
/// The action registry maintains a mapping from action IDs to their executable closures.
/// When a client sends an action, the server looks it up and executes it.
///
/// ## Usage
///
/// ```swift
/// // Register an action
/// let action = Action {
///     count += 1
/// }
/// ActionRegistry.current.register(action)
///
/// // Later, execute it
/// ActionRegistry.current.execute(action.id)
/// ```
///
/// ## Session Scoping
///
/// Like `StateStore`, the action registry is scoped per session. Each session
/// has its own set of actions.
///
/// - SeeAlso: `Action`, `SessionManager`
public final class ActionRegistry: @unchecked Sendable {
    /// The current action registry for this execution context.
    nonisolated(unsafe) public static var current: ActionRegistry = ActionRegistry()
    
    private var actions: [ActionID: Action] = [:]
    private let lock = NSLock()
    
    /// Creates a new action registry.
    public init() {}
    
    /// Registers an action.
    ///
    /// - Parameter action: The action to register.
    public func register(_ action: Action) {
        lock.lock()
        defer { lock.unlock() }
        actions[action.id] = action
    }
    
    /// Executes an action by its ID.
    ///
    /// - Parameter actionId: The action identifier.
    /// - Returns: `true` if the action was found and executed, `false` otherwise.
    @discardableResult
    public func execute(_ actionId: ActionID) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let action = actions[actionId] else {
            return false
        }
        action.execute()
        return true
    }
    
    /// Gets the number of registered actions.
    ///
    /// Useful for debugging.
    public var actionCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return actions.count
    }
    
    /// Clears all registered actions.
    ///
    /// Called when a session ends.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        actions.removeAll()
    }
}

/// Manages action registries per session.
///
/// Extension to `SessionManager` to handle action registries alongside state stores.
extension SessionManager {
    nonisolated(unsafe) private static var actionRegistries: [String: ActionRegistry] = [:]
    private static let actionRegistriesLock = NSLock()
    
    /// Activates a session's action registry.
    ///
    /// - Parameter sessionId: The session identifier.
    /// - Returns: The action registry for this session.
    @discardableResult
    public func activateActionRegistry(_ sessionId: String) -> ActionRegistry {
        Self.actionRegistriesLock.lock()
        defer { Self.actionRegistriesLock.unlock() }
        
        let registry: ActionRegistry
        if let existing = Self.actionRegistries[sessionId] {
            registry = existing
        } else {
            registry = ActionRegistry()
            Self.actionRegistries[sessionId] = registry
        }
        ActionRegistry.current = registry
        return registry
    }
    
    /// Removes a session's action registry.
    ///
    /// - Parameter sessionId: The session identifier.
    public func removeActionRegistry(_ sessionId: String) {
        Self.actionRegistriesLock.lock()
        defer { Self.actionRegistriesLock.unlock() }
        Self.actionRegistries.removeValue(forKey: sessionId)
    }
}

