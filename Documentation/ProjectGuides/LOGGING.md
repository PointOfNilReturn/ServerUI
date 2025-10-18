# Logging Implementation

## Overview

ServerUI now uses [swift-log](https://github.com/apple/swift-log) for structured, production-ready logging throughout the codebase.

## Dependencies

### ClientUI
- **Package**: `swift-log` (1.5.0+)
- **Product**: `Logging`

### ServerApp
- **Package**: `swift-log` (1.5.0+)
- **Product**: `Logging`

## Logger Labels

Each component uses a descriptive label for easy filtering:

| Component | Label | Purpose |
|-----------|-------|---------|
| `PathNavigator` | `com.serverui.pathnavigator` | Path-based navigation requests |
| `PathNavigationLink` | `com.serverui.pathnavigationlink` | Navigation link interactions |
| `ServerBootstrap` | `com.serverui.server` | Server lifecycle |
| `ServerApp` | `com.serverui.app` | Application lifecycle |

## Log Levels Used

### `.debug` - Development Information
Used for detailed information useful during development:
```swift
logger.debug("Fetching view hierarchy", metadata: ["url": "\(url)"])
```

### `.info` - General Information
Used for significant events:
```swift
logger.info("Server started", metadata: ["port": "8080"])
```

### `.warning` - Potential Issues
Used for non-fatal issues that should be investigated:
```swift
logger.warning("PathNavigator not found in environment")
```

### `.error` - Errors
Used for failures that are handled but indicate problems:
```swift
logger.error("Failed to fetch view hierarchy", metadata: ["error": "\(error)"])
```

### `.critical` - Critical Failures
Used for unrecoverable errors:
```swift
logger.critical("Failed to start server", metadata: ["error": "\(error)"])
```

## Usage Examples

### Basic Logging
```swift
import Logging

struct MyComponent {
    private let logger = Logger(label: "com.serverui.mycomponent")
    
    func doSomething() {
        logger.info("Starting operation")
        // ... work ...
        logger.info("Operation completed")
    }
}
```

### Logging with Metadata
```swift
logger.debug("Processing request", metadata: [
    "path": "\(path)",
    "method": "\(method)",
    "timestamp": "\(Date())"
])
```

### Error Logging
```swift
do {
    try riskyOperation()
} catch {
    logger.error("Operation failed", metadata: [
        "error": "\(error.localizedDescription)",
        "context": "Additional context here"
    ])
    throw error
}
```

## Console vs Logging

### When to use `print()`
Only for **direct user communication** in CLI applications:
```swift
// ✅ User-facing output
print("➡️  Listening on http://127.0.0.1:8080")
print("✅ Build complete!")
```

### When to use `logger`
For **all diagnostic/debugging information**:
```swift
// ✅ Structured logging
logger.info("Server started", metadata: ["port": "8080"])
logger.debug("Processing request", metadata: ["path": "/screen/home"])
```

## Configuration

### Default Behavior
By default, `swift-log` logs to `stdout` with basic formatting.

### Custom Log Handlers
For production, you can configure custom handlers:
```swift
// In your app initialization
import Logging

LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardOutput(label: label)
    handler.logLevel = .info  // Only log .info and above
    return handler
}
```

### Environment-Based Configuration
```swift
#if DEBUG
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        handler.logLevel = .debug  // Verbose in debug
        return handler
    }
#else
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        handler.logLevel = .info  // Quiet in production
        return handler
    }
#endif
```

## Best Practices

### ✅ Do
- Use structured metadata instead of string interpolation
- Choose appropriate log levels
- Include relevant context in metadata
- Use consistent label naming (`com.serverui.<component>`)

### ❌ Don't
- Don't log sensitive information (passwords, tokens)
- Don't log in tight loops (performance)
- Don't use `print()` for diagnostic information
- Don't log large objects/data

## Example: Migrating from print()

### Before
```swift
print("⚠️ Failed to fetch: \(url)")
```

### After
```swift
logger.error("Failed to fetch view hierarchy", metadata: [
    "url": "\(url)",
    "error": "\(error.localizedDescription)"
])
```

## Benefits

1. **Structured**: Logs include structured metadata for easy parsing
2. **Configurable**: Log levels can be adjusted per environment
3. **Searchable**: Labels and metadata make logs easy to filter
4. **Production-ready**: Industry-standard logging suitable for production
5. **Performance**: Efficient and low-overhead

## Further Reading

- [swift-log Documentation](https://github.com/apple/swift-log)
- [Logging Best Practices](https://github.com/apple/swift-log#best-practices)

