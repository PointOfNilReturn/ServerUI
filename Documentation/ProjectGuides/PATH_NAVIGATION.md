# Path-Based Navigation Implementation

## Overview

ServerUI now supports **flexible navigation** with two distinct modes:

1. **Embedded Navigation** (SwiftUI-mirroring) - Destination views encoded in initial JSON
2. **Path-Based Navigation** (On-demand) - Destination views fetched lazily when needed

This gives developers the flexibility to choose the best approach for their use case.

---

## Architecture

### Server-Side (`ServerUI`)

#### NavigationLinkSpec (ViewSchema)
```swift
public enum NavigationLinkSpec: Codable, Equatable, Sendable {
    case embedded                                          // SwiftUI-mirroring
    case absolutePath(String)                              // /screen/profile
    case relativePath(String)                              // settings
    case absolutePathWithQuery(path: String, query: [String: String])  // /user?id=123
    case relativePathWithQuery(path: String, query: [String: String])  // details?tab=info
}
```

#### NavigationLink API
```swift
// Option 1: Embedded (current SwiftUI pattern)
NavigationLink("Details") {
    DetailView()  // Encoded immediately
}

// Option 2: Absolute path
NavigationLink("Profile", absolutePath: "/screen/profile")

// Option 3: Relative path
NavigationLink("Settings", relativePath: "settings")

// Option 4: With query parameters
NavigationLink("User", absolutePath: "/user", query: ["id": "123"])

// Option 5: Type-safe path builder
NavigationLink("Details", path: .relative("details"))
```

### Client-Side (`ClientUI`)

#### RemoteConfiguration
Already existed! Provides:
- `baseURL` - Server endpoint
- `initialPath` - Starting route
- `transport` - HTTP polling config
- `headersProvider` - Dynamic auth headers
- `sessionConfiguration` - URLSession customization

#### PathNavigator (New)
- `@Observable` class (iOS 17+ modern pattern)
- Fetches JSON from server paths
- Resolves absolute vs relative paths
- Builds query strings
- Tracks current path for relative resolution

#### PathNavigationLink (New)
- Renders as Button initially
- Fetches destination on tap
- Shows loading indicator
- Error handling with alerts
- Converts to NavigationLink once fetched

---

## Usage Examples

### Server-Side Setup

```swift
// In your route handler
enum Router {
    static func respond(method: String, path: String) -> Data {
        switch path {
        case "/screen/home":
            return HomeScreenHandler.response()
        case "/screen/profile":
            return ProfileScreenHandler.response()
        case let p where p.hasPrefix("/user"):
            return UserScreenHandler.response(path: p)
        default:
            return errorResponse()
        }
    }
}
```

### Client-Side Setup

```swift
import ClientUI
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RemoteView(.local()) // or custom RemoteConfiguration
        }
    }
}
```

That's it! The `RemoteView` automatically:
- Creates a `PathNavigator` with your configuration
- Injects it into the environment
- Handles both embedded and path-based navigation

---

## Benefits

### Embedded Navigation
✅ Mirrors SwiftUI exactly  
✅ No extra network requests  
✅ Works offline once loaded  
✅ Instant navigation  

❌ Larger initial payload  
❌ All destinations must be known upfront  

### Path-Based Navigation
✅ Smaller initial payload  
✅ Fresh data on each navigation  
✅ Scalable for large apps  
✅ Can be cached/prefetched  
✅ Server-side routing flexibility  

❌ Network request on navigation  
❌ Loading state handling  
❌ Requires internet connection  

---

## Advanced Features

### Query Parameters
```swift
// Server encodes
NavigationLink("User Profile", absolutePath: "/user", query: ["id": "123", "tab": "posts"])

// Server receives
// Path: /user?id=123&tab=posts

// Parse on server
let userId = extractQueryParam(from: path, key: "id")
```

### Relative Path Resolution
```swift
// Current path: /screen/home
NavigationLink("Settings", relativePath: "settings")
// Resolves to: /screen/home/settings
```

### Type-Safe Paths
```swift
// Use NavigationPath builder for compile-time safety
NavigationLink("Details", path: .relative("details"))
NavigationLink("Profile", path: .absolute("/screen/profile"))
NavigationLink("User", path: .absoluteWithQuery("/user", query: ["id": "123"]))

// Convenience for single params
NavigationLink("User", path: .absolute("/user", "id", "123"))
```

### Custom Headers & Auth
```swift
RemoteConfiguration(
    baseURL: URL(string: "https://api.example.com")!,
    initialPath: "/screen/home",
    headersProvider: {
        ["Authorization": "Bearer \(getToken())"]
    }
)
```

---

## Testing

### Server Routes Verified
- ✅ `/screen/home` - Home screen with navigation examples
- ✅ `/screen/profile` - Absolute path navigation
- ✅ `/screen/home/settings` - Relative path navigation
- ✅ `/screen/home/details` - Type-safe path navigation
- ✅ `/user?id=123` - Query parameter navigation

### Build Status
- ✅ ServerUI package builds
- ✅ ClientUI package builds
- ✅ ViewSchema package builds
- ✅ Sample ServerApp builds
- ✅ All routes return valid JSON

---

## Implementation Details

### Encoding Logic
- **Embedded**: Both label and destination encoded as children
- **Path-based**: Only label encoded, destination is `null`

### Client Rendering
- **Embedded**: Renders SwiftUI `NavigationLink` immediately
- **Path-based**: Renders `Button` → Fetches → Converts to `NavigationLink`

### Error Handling
- Network errors show alert with retry option
- Missing `PathNavigator` logs warning
- Failed encoding returns error JSON
- 404s handled gracefully

---

## Future Enhancements

- [ ] Client-side caching of fetched destinations
- [ ] Prefetching for predicted navigation
- [ ] SwiftUI `NavigationPath` integration for programmatic navigation
- [ ] Deep linking support
- [ ] Navigation history/stack management
- [ ] Transition animations
- [ ] Network retry policies
- [ ] Progress indicators for slow connections

---

## Migration Guide

Existing embedded navigation continues to work with **zero changes**. To add path-based navigation:

1. Add new server routes
2. Use path-based `NavigationLink` initializers
3. That's it! The infrastructure is automatic.

No breaking changes to existing code.

