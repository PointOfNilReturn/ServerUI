# ``ViewSchema``

The shared JSON schema for server-client communication.

## Overview

ViewSchema defines the JSON structure used to encode SwiftUI-like views for transmission between server and client. It's a pure data layer with no dependencies beyond Foundation.

### Key Concepts

- **Platform agnostic**: Works with any JSON-capable system
- **Codable**: Automatic JSON encoding/decoding
- **Sendable**: Safe for concurrent use
- **Equatable & Hashable**: Support for navigation and diffing

### Structure

```
ViewHierarchy
└── ViewNode
    ├── ViewType (Text, VStack, HStack, etc.)
    ├── Modifiers (font, padding, frame, etc.)
    └── Children (nested ViewNodes)
```

### Example JSON

```json
{
  "schemaVersion": 1,
  "viewHierarchy": {
    "root": {
      "type": {
        "text": {
          "localized": "Hello, World!"
        }
      },
      "modifiers": [
        { "font": "largeTitle" }
      ],
      "children": []
    }
  }
}
```

## Topics

### Core Types

- ``ViewHierarchy``
- ``ViewNode``
- ``ViewType``
- ``Modifier``

### View Specifications

- ``TextSpec``
- ``VStackSpec``
- ``HStackSpec``
- ``NavigationStackSpec``
- ``NavigationLinkSpec``

### Modifier Specifications

- ``PaddingSpec``
- ``FrameSpec``
- ``AlignmentSpec``
- ``FontRole``

### Envelopes

- ``ViewHierarchyEnvelope``

## See Also

- [ServerUI](x-source-tag://ServerUI) - Encodes views to this schema
- [ClientUI](x-source-tag://ClientUI) - Decodes and renders this schema

