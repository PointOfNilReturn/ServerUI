# ``ServerUI``

Build server-driven SwiftUI applications with a familiar declarative API.

## Overview

ServerUI is a Swift framework that mirrors SwiftUI's API on the server-side. Instead of rendering views directly, it encodes your view hierarchies into JSON that can be sent to clients and rendered with native SwiftUI.

This enables:
- **Server-driven UI**: Control your app's interface from the server
- **Hot updates**: Change UI without app updates
- **Consistent API**: If you know SwiftUI, you know ServerUI
- **Type safety**: Full compile-time checking

### Quick Start

```swift
import ServerUI

struct WelcomeScreen: View {
    var body: some View {
        VStack {
            Text("Welcome to ServerUI")
                .font(.largeTitle)
            
            Text("Build native UIs from the server")
                .font(.body)
                .padding()
        }
        .navigationTitle("Welcome")
    }
}

// Encode to JSON
let json = try ServerUIJSON.encode(WelcomeScreen())
```

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Architecture>
- <doc:NavigationPatterns>

### Core Concepts

- <doc:ViewBuilderGuide>
- <doc:InitializerFidelity>
- <doc:PathNavigation>

### Views

- ``View``
- ``Text``
- ``VStack``
- ``HStack``
- ``NavigationStack``
- ``NavigationLink``

### View Modifiers

- ``ModifiedContent``

### Encoding

- ``ServerUIJSON``

## See Also

- [ClientUI](x-source-tag://ClientUI) - The client-side renderer
- [ViewSchema](x-source-tag://ViewSchema) - The shared JSON schema

