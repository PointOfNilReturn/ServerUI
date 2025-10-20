# ``ClientUI``

Render server-driven UI with native SwiftUI.

## Overview

ClientUI is the client-side companion to ServerUI. It fetches JSON view hierarchies from your server and renders them with native SwiftUI components.

### Features

- **Native rendering**: Real SwiftUI views, not web views
- **Instant reactivity**: Reactive state cache for 0ms UI updates
- **Automatic updates**: Poll or fetch on-demand
- **Navigation support**: Both embedded and path-based
- **State management**: Seamless @State and @Observable support
- **Offline handling**: Graceful error states
- **Flexible configuration**: Custom headers, base URLs, polling

### Quick Start

```swift
import ClientUI
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RemoteView(.local()) // Connect to localhost:8080
        }
    }
}
```

### Advanced Configuration

```swift
RemoteView(
    RemoteConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        initialPath: "/screen/home",
        transport: .httpPolling(seconds: 5),
        headersProvider: {
            ["Authorization": "Bearer \(getToken())"]
        }
    )
)
```

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:RemoteConfiguration>
- <doc:Logging>

### Main Views

- ``RemoteView``
- ``ViewRenderer``

### State Management

- <doc:ReactiveStateCache>
- ``ReactiveStateCache``
- ``StateUpdater``
- ``ActionExecutor``

### Navigation

- ``PathNavigator``
- <doc:PathNavigation>

### Configuration

- ``RemoteConfiguration``
- ``Transport``

## See Also

- [ServerUI](x-source-tag://ServerUI) - The server-side API
- [ViewSchema](x-source-tag://ViewSchema) - The shared JSON schema

