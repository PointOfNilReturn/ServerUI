# Getting Started with ServerUI

Learn how to build your first server-driven UI application.

## Overview

ServerUI lets you build native iOS/macOS applications controlled from the server. This guide walks you through creating your first screen.

## Installation

Add ServerUI to your server-side Swift project:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/yourusername/ServerUI", from: "1.0.0")
]
```

## Your First View

Create a simple view using familiar SwiftUI syntax:

```swift
import ServerUI

struct WelcomeScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.largeTitle)
            
            Text("This UI is rendered from the server")
                .font(.body)
                .padding()
        }
        .navigationTitle("Home")
    }
}
```

## Encoding to JSON

Convert your view to JSON for transmission:

```swift
let json = try ServerUIJSON.encode(WelcomeScreen())
// Send json to your client
```

## Setting Up a Server

Here's a basic HTTP server endpoint:

```swift
import Foundation

func handleRequest(path: String) -> Data {
    let view = WelcomeScreen()
    let json = (try? ServerUIJSON.encode(view)) ?? Data()
    return json
}
```

## Available Views

ServerUI supports these view types:

- **Text**: Display text with various initializers
- **VStack/HStack**: Layout views vertically/horizontally
- **NavigationStack**: Container for navigation
- **NavigationLink**: Navigate to other screens

## Available Modifiers

Style your views with modifiers:

- `.font(_:)` - Text styling
- `.padding()` - Add spacing
- `.frame()` - Control size
- `.navigationTitle(_:)` - Screen titles

## Next Steps

- <doc:Architecture> - Understand how it works
- <doc:NavigationPatterns> - Build multi-screen apps
- <doc:InitializerFidelity> - Advanced text handling

