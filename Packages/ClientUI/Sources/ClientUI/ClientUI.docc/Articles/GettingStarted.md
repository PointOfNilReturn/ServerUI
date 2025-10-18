# Getting Started with ClientUI

Learn how to render server-driven UI in your iOS or macOS app.

## Overview

ClientUI connects your SwiftUI app to a ServerUI backend, fetching and rendering UI dynamically. This guide shows you how to set up your first client.

## Installation

Add ClientUI to your iOS/macOS project:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/yourusername/ServerUI", from: "1.0.0")
]
```

## Basic Setup

The simplest way to get started:

```swift
import ClientUI
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RemoteView(.local())
        }
    }
}
```

This connects to `http://127.0.0.1:8080` and fetches from `/screen/home`.

## Custom Configuration

For production apps, configure your server connection:

```swift
let config = RemoteConfiguration(
    baseURL: URL(string: "https://api.yourapp.com")!,
    initialPath: "/screen/home",
    transport: .httpOnce  // Or .httpPolling(seconds: 5)
)

RemoteView(config)
```

## Adding Authentication

Provide custom headers for authentication:

```swift
RemoteConfiguration(
    baseURL: yourURL,
    initialPath: "/screen/home",
    headersProvider: {
        [
            "Authorization": "Bearer \(getAuthToken())",
            "X-User-ID": "\(getCurrentUserID())"
        ]
    }
)
```

The `headersProvider` closure is called for each request, allowing you to fetch fresh tokens.

## Transport Modes

Choose how often to update:

### HTTP Once
Fetch once on launch:
```swift
transport: .httpOnce
```

### HTTP Polling
Continuously poll for updates:
```swift
transport: .httpPolling(seconds: 5)  // Every 5 seconds
```

## Error Handling

ClientUI automatically shows error states:

- **Loading**: Shows `ProgressView("Loading…")`
- **Error**: Shows `ContentUnavailableView` with retry button
- **Success**: Renders your server-driven UI

## Navigation

ClientUI supports both navigation modes:

### Embedded Navigation
Destination views included in JSON (no extra requests)

### Path-Based Navigation
Destinations fetched on-demand (See <doc:PATH_NAVIGATION>)

## Next Steps

- <doc:RemoteConfiguration> - Advanced configuration
- <doc:PATH_NAVIGATION> - On-demand navigation
- <doc:LOGGING> - Debugging and logging

