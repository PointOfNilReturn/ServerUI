# Reactive State Cache

A client-side reactive cache that provides instant UI updates while maintaining the server as the source of truth.

## Overview

The `ReactiveStateCache` is the cornerstone of ServerUI's instant responsiveness. It bridges server-driven state management with native SwiftUI performance by maintaining a local cache of state values that updates instantly while synchronizing with the server in the background.

## Architecture

```
Server → [ViewHierarchy + initialState] → Client
                                            ↓
                                    ReactiveStateCache
                                    (initialized from server)
                                            ↓
                                    All Views Bind to Cache
                                    (instant reads/writes!)
                                            ↓
                                    Cache → Server (debounced)
                                            ↓
                                    Server Response → Cache
```

### Key Principles

1. **Server as Source of Truth**: The cache is always initialized and updated from server state
2. **Instant Local Updates**: All reads and writes are instant (0ms latency)
3. **Automatic Synchronization**: Changes are debounced and synced to the server automatically
4. **Race Condition Prevention**: Pending local changes are protected from stale server responses

## How It Works

### Initialization

When a view hierarchy loads, the cache is initialized with the server's current state:

```swift
// Server sends ViewHierarchy with initialState
let hierarchy = ViewHierarchy(
    root: viewNode,
    initialState: [
        "user_id::name": .string("John"),
        "user_id::email": .string("john@example.com")
    ]
)

// Client initializes cache
reactiveCache.initialize(hierarchy.initialState)
```

### Instant Updates

Components bind directly to the cache for instant read/write access:

```swift
// TextField binds to cache
TextField("Name", text: cache.binding(for: stateKey))

// User types "Jane" → cache updates INSTANTLY (0ms!)
// Cache automatically debounces and syncs to server (300ms)
```

### Server Synchronization

The cache handles all server communication automatically:

1. **User makes change** → Cache updates immediately
2. **After debounce delay** → Cache sends update to server
3. **Server processes** → Returns updated state
4. **Cache receives update** → Refreshes (unless newer local changes exist)

### Race Condition Prevention

The cache tracks pending updates to prevent flashing:

```swift
// Scenario: User types quickly then deletes

// 1. User types "ABC" → cache = "ABC" (marked pending)
// 2. User deletes → cache = "AB" (marked pending)
// 3. Server response for "ABC" arrives → SKIPPED (pending!)
// 4. StateUpdater confirms "ABC" → clears pending
// 5. Server response for "AB" arrives → SKIPPED (pending!)
// 6. StateUpdater confirms "AB" → clears pending

// Result: No flash! UI stays smooth 🎉
```

## Usage in Components

### TextField (Built-in)

`DebouncedTextField` automatically uses the cache:

```swift
// Server-side: ServerUI
TextField("Name", text: $user.name)

// Client-side: Rendered automatically
// User typing is instant, syncs to server in background
```

### Text with Bindings

`Text(binding:)` creates state-bound text that reads from the cache:

```swift
// Server-side: Display bound text
@Bindable var profile: UserProfile
Text(binding: $profile.name) // ← Creates stateBound spec

// Client-side: OptimisticText reads from cache
// Updates instantly as user types in TextField
```

### Custom Components

Any component can access the cache via environment:

```swift
@Environment(\.reactiveStateCache) private var cache

var body: some View {
    if let cache = cache {
        let value: String = cache.get("my_key") ?? "default"
        Text(value)
    }
}
```

## Performance

The `ReactiveStateCache` provides:

- **0ms read latency**: All property reads are instant
- **0ms write latency**: All property writes are instant
- **300ms debounce**: Server updates are batched to reduce network traffic
- **Smart caching**: Stale server responses are automatically ignored

## Implementation Details

### State Value Types

The cache supports common UI state types via the `StateValue` enum:

```swift
public enum StateValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
}
```

### Pending Update Tracking

```swift
private var pendingUpdates: Set<String> = []

public func set<T>(_ key: String, value: T) {
    storage[key] = value
    pendingUpdates.insert(key)  // Mark as pending
    stateUpdater?.updateState(key, value: stringValue)
}

public func confirmUpdate(_ key: String) {
    pendingUpdates.remove(key)  // Clear when confirmed
}
```

### Server Update Handling

```swift
public func initialize(_ initialState: [String: StateValue]) {
    for (key, value) in initialState {
        if pendingUpdates.contains(key) {
            continue  // Skip keys with pending updates
        }
        storage[key] = value.anyValue
    }
}
```

## Observable Objects

The cache seamlessly integrates with `@RemotelyObservable` objects:

```swift
@RemotelyObservable
class UserProfile {
    var name: String = ""
    var email: String = ""
}

// Properties are stored as "objectID::propertyName"
// Cache provides instant updates for all properties
```

## Best Practices

### Use Bindings for Instant Updates

For text that should update instantly as the user types, use `Text(binding:)`:

```swift
// ✅ Good: Instant updates
@Bindable var profile: UserProfile
Text(binding: $profile.name)

// ❌ Avoid: Only updates after server confirms
Text("Name: \(profile.name)")
```

### Let the Cache Handle Debouncing

Don't implement your own debouncing - the cache handles it:

```swift
// ✅ Good: Cache handles debouncing
TextField("Name", text: $user.name)

// ❌ Avoid: Manual debouncing conflicts with cache
```

### Trust the Pending Update System

The cache automatically prevents race conditions:

```swift
// ✅ Good: Trust the system
// Rapid typing and deleting "just works"

// ❌ Avoid: Manual state reconciliation
// The cache already handles this
```

## Related Documentation

- ``StateUpdater`` - Handles debouncing and server communication
- ``DebouncedTextField`` - Text field component using the cache
- ``OptimisticText`` - Text view that reads from the cache
- <doc:Logging> - Debugging cache behavior

## See Also

- <doc:PathNavigation>
- <doc:RemoteConfiguration>

