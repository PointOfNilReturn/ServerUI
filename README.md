# ServerUI

> **Server-driven SwiftUI**: Write familiar SwiftUI code on your server, render natively on the client.

ServerUI enables you to build iOS/macOS applications where the UI is defined and controlled by your server, but rendered using native SwiftUI on the client. This provides a powerful architecture for dynamic interfaces, A/B testing, feature flags, and keeping business logic server-side while maintaining native app performance and feel.

## Overview

ServerUI mirrors the SwiftUI API on the server side. Views are encoded into a JSON schema, transmitted to the client, and rendered as native SwiftUI components. The system consists of three main packages:

- **ServerUI** - Server-side view DSL and encoding engine
- **ViewSchema** - Shared JSON schema definitions
- **ClientUI** - Client-side JSON decoder and SwiftUI renderer

## Quick Example

### Server Code (macOS/Linux)

```swift
import ServerUI

struct WelcomeScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to ServerUI!")
                .font(.largeTitle)
            
            Text("Build UI on the server")
                .font(.headline)
            
            HStack(spacing: 15) {
                Text("Native")
                Text("•")
                Text("Dynamic")
                Text("•")
                Text("Swift")
            }
            .font(.body)
        }
    }
}

// Encode to JSON
let jsonData = try ServerUIJSON.encode(WelcomeScreen())
// Send jsonData over HTTP...
```

### Client Code (iOS/macOS)

```swift
import ClientUI
import SwiftUI

struct ContentView: View {
    var body: some View {
        RemoteView(.local(port: 8080, path: "/screen/home"))
    }
}
```

The client automatically fetches, decodes, and renders the server-defined UI using native SwiftUI components.

## Architecture

### Initializer Fidelity

ServerUI preserves **which initializer** was used to create a view, not just the resulting data. This is a core architectural principle that ensures the server's intent is accurately reflected on the client.

For example, `Text` has multiple initializers with different behaviors:

```swift
Text("greeting.hello")           // Localized - looks up in .strings files
Text(verbatim: "©2024 Acme")     // Literal - renders as-is
```

Both contain strings, but they should be rendered differently. ServerUI encodes this distinction:

```json
{
  "type": { "text": { "_0": { "localized": { "_0": "greeting.hello" } } } }
}
```

The client then calls the appropriate SwiftUI initializer. This pattern applies to all views and ensures:
- ✅ Proper localization support
- ✅ Platform-specific rendering
- ✅ Type safety
- ✅ Future compatibility

See [Documentation/ProjectGuides/INITIALIZER_FIDELITY.md](Documentation/ProjectGuides/INITIALIZER_FIDELITY.md) for detailed documentation.

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                         SERVER                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  struct MyView: View {                             │    │
│  │      var body: some View {                         │    │
│  │          VStack {                                   │    │
│  │              Text("Hello")                          │    │
│  │              Text("World")                          │    │
│  │          }                                          │    │
│  │      }                                              │    │
│  │  }                                                  │    │
│  └────────────────────────────────────────────────────┘    │
│                           ↓                                 │
│                  ServerUIJSON.encode()                      │
│                           ↓                                 │
│  ┌────────────────────────────────────────────────────┐    │
│  │  {                                                  │    │
│  │    "schemaVersion": 1,                             │    │
│  │    "viewHierarchy": {                              │    │
│  │      "root": {                                      │    │
│  │        "type": "vstack",                            │    │
│  │        "children": [...]                            │    │
│  │      }                                              │    │
│  │    }                                                │    │
│  │  }                                                  │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                           │
                    HTTP / WebSocket
                           │
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT (iOS/macOS)                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  RemoteView(...)                                   │    │
│  │     ↓                                               │    │
│  │  Fetch JSON                                        │    │
│  │     ↓                                               │    │
│  │  Decode to ViewHierarchy                           │    │
│  │     ↓                                               │    │
│  │  ViewRenderer → Native SwiftUI                     │    │
│  └────────────────────────────────────────────────────┘    │
│                           ↓                                 │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Native SwiftUI Rendering                   │    │
│  │  ┌──────────────────────────────────────────┐     │    │
│  │  │  Hello                                    │     │    │
│  │  │  World                                    │     │    │
│  │  └──────────────────────────────────────────┘     │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. View Protocol & ViewBuilder

ServerUI's `View` protocol mirrors SwiftUI's design:

```swift
protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}
```

The `@ViewBuilder` result builder enables declarative syntax using Swift's powerful type system.

#### 2. Encoding Engine

The encoding engine recursively traverses view hierarchies and converts them to JSON:

- **View Decomposition**: Custom views are decomposed via their `body` property until only primitives remain
- **Node Construction**: Each primitive becomes a `ViewNode` with type, children, and modifiers
- **Type Erasure**: Protocol-based extraction handles generic types like `VStack<TupleView<...>>`

#### 3. Parameter Pack Innovation

Unlike SwiftUI which limits containers to 10 children (via 2-10 explicit overloads), ServerUI uses Swift 5.9+ parameter packs for **unlimited children**:

```swift
public static func buildBlock<C0: View, C1: View, C2: View, each Content: View>(
    _ c0: C0, _ c1: C1, _ c2: C2, _ content: repeat each Content
) -> TupleView<C0, C1, C2, repeat each Content>
```

This means you can have as many children as needed without hitting arbitrary limits.

## Supported Views & Modifiers

### Container Views
- **VStack** - Vertical stack layout (with alignment & spacing)
- **HStack** - Horizontal stack layout (with alignment & spacing)
- **NavigationStack** - Navigation container
- **NavigationLink** - Navigate to other screens (embedded & path-based)

### Primitive Views
- **Text** - Text display (with 6+ initializers: localized, verbatim, markdown, dates, ranges, timers)
- **EmptyView** - Empty placeholder

### Modifiers
- `.font(_:)` - Text styling (largeTitle, title, headline, body, footnote, caption)
- `.padding()` - Add spacing (default, custom amount, specific edges)
- `.frame()` - Control size (fixed, min/max, alignment)
- `.navigationTitle(_:)` - Screen titles

### Control Flow
- **if / else** - Conditional rendering
- **if** (optional) - Optional rendering
- **Unlimited children** - No 10-child limit (via parameter packs)

## Requirements

- **Server**: macOS 14.0+ / Linux (Swift 5.9+)
- **Client**: iOS 17.0+ / macOS 14.0+
- **Swift**: 5.9+ (for parameter pack support)

## Installation

### Swift Package Manager

Add ServerUI to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ServerUI.git", from: "0.1.0")
]
```

For server targets:
```swift
.target(
    name: "MyServer",
    dependencies: [
        .product(name: "ServerUI", package: "ServerUI")
    ]
)
```

For client targets:
```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "ClientUI", package: "ServerUI")
    ]
)
```

## Usage

### Server Setup

```swift
import Foundation
import ServerUI

// Define your view
struct DashboardView: View {
    let userName: String
    let metrics: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Dashboard")
                .font(.largeTitle)
            
            Text("Welcome, \(userName)!")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                for metric in metrics {
                    HStack {
                        Text("•")
                        Text(metric)
                    }
                    .font(.body)
                }
            }
        }
    }
}

// Encode to JSON
let view = DashboardView(
    userName: "Alice",
    metrics: ["Users: 1,234", "Revenue: $5,678", "Conversion: 3.2%"]
)
let jsonData = try ServerUIJSON.encode(view)

// Send over HTTP
// response.send(jsonData)
```

### Client Setup

```swift
import SwiftUI
import ClientUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RemoteView(
                RemoteConfiguration(
                    baseURL: URL(string: "https://api.example.com")!,
                    initialPath: "/screen/dashboard",
                    transport: .httpPolling(seconds: 5)
                )
            )
        }
    }
}
```

## Advanced Features

### Custom Views

Create reusable components just like in SwiftUI:

```swift
struct ProfileCard: View {
    let name: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
        }
    }
}

// Use in other views
struct TeamView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProfileCard(name: "Alice", subtitle: "Engineer")
            ProfileCard(name: "Bob", subtitle: "Designer")
        }
    }
}
```

### Conditional Rendering

```swift
struct ContentView: View {
    let isLoggedIn: Bool
    
    var body: some View {
        VStack {
            if isLoggedIn {
                Text("Welcome back!")
                    .font(.title)
            } else {
                Text("Please log in")
                    .font(.body)
            }
        }
    }
}
```

### Dynamic Content

```swift
struct ItemListView: View {
    let items: [String]
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Items")
                .font(.headline)
            
            for item in items {
                Text(item)
                    .font(.body)
            }
        }
    }
}
```

## JSON Schema

The encoded JSON follows this structure:

```json
{
  "schemaVersion": 1,
  "viewHierarchy": {
    "root": {
      "type": {
        "vstack": {
          "_0": {
            "alignment": "leading",
            "spacing": 20
          }
        }
      },
      "children": [
        {
          "type": {
            "text": {
              "_0": {
                "string": {
                  "_0": "Hello, World!"
                }
              }
            }
          },
          "modifiers": [
            {
              "font": {
                "_0": "largeTitle"
              }
            }
          ],
          "children": []
        }
      ],
      "modifiers": []
    }
  }
}
```

## Documentation

Comprehensive DocC documentation is available:

### View in Xcode
1. Open `ServerUI.xcworkspace`
2. **Product → Build Documentation** (⌃⇧⌘D)
3. Browse in Xcode's documentation viewer

### Documentation Structure
- **API Documentation**: Inline DocC comments in `.docc` catalogs
- **Project Guides**: See `Documentation/` folder
- **Getting Started**: See package-specific guides in each `.docc` catalog

For details, see [Documentation/DOCUMENTATION.md](Documentation/DOCUMENTATION.md)

## Use Cases

- **A/B Testing**: Dynamically change UI layouts without app updates
- **Feature Flags**: Control feature visibility server-side
- **Personalization**: Customize UI per user, region, or context
- **Rapid Iteration**: Update UI instantly without App Store review
- **Business Logic Security**: Keep sensitive logic on the server
- **Dynamic Forms**: Server-driven form generation and validation
- **Content Management**: Non-technical teams can modify layouts

## Roadmap

### Completed ✅
- [x] NavigationStack & NavigationLink (embedded & path-based)
- [x] Text with multiple initializers (localized, verbatim, markdown, dates, timers)
- [x] VStack / HStack with alignment & spacing
- [x] Modifiers: `.font()`, `.padding()`, `.frame()`, `.navigationTitle()`
- [x] ViewBuilder with unlimited children (parameter packs)
- [x] Structured logging (swift-log)
- [x] DocC documentation

### In Progress / Next
- [ ] Button with action callbacks
- [ ] List & ForEach for dynamic collections
- [ ] Image support (SF Symbols, remote URLs)
- [ ] TextField and form inputs
- [ ] ScrollView
- [ ] More modifiers (background, foregroundStyle, cornerRadius, opacity)
- [ ] Spacer and Divider
- [ ] State management (@State equivalent)
- [ ] WebSocket transport
- [ ] Delta updates for performance
- [ ] Animation support

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure documentation is updated
5. Submit a pull request

## License

[Your License Here]

## Acknowledgments

ServerUI is inspired by:
- **SwiftUI** - Apple's declarative UI framework
- **Jetpack Compose** - Android's modern UI toolkit
- **React Server Components** - Server-side rendering patterns

---

Built with ❤️ using Swift and modern language features like parameter packs and result builders.

