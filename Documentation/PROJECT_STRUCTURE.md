# Project Structure

This document explains the organization of the ServerUI project.

## Directory Layout

```
ServerUI/
├── README.md                                    # Main project overview
├── Documentation/                               # Project documentation
│   ├── README.md                               # Documentation index
│   ├── DOCUMENTATION.md                        # How to build/view docs
│   ├── DOCC_SETUP.md                          # DocC setup summary
│   ├── PROJECT_STRUCTURE.md                   # This file
│   └── ProjectGuides/                         # Historical/reference guides
│       ├── ARCHITECTURE.md
│       ├── INITIALIZER_FIDELITY.md
│       ├── LOGGING.md
│       ├── NAVIGATION_PATTERNS.md
│       ├── PATH_NAVIGATION.md
│       └── SINGLE_TAP_NAVIGATION_FIX.md
│
├── Packages/                                   # Swift packages
│   ├── ServerUI/                              # Server-side API
│   │   ├── Package.swift
│   │   └── Sources/ServerUI/
│   │       ├── ServerUI.docc/                 # API documentation
│   │       │   ├── ServerUI.md               # Overview
│   │       │   └── Articles/                 # Guides
│   │       │       ├── GettingStarted.md
│   │       │       ├── Architecture.md
│   │       │       ├── NavigationPatterns.md
│   │       │       ├── PathNavigation.md
│   │       │       ├── InitializerFidelity.md
│   │       │       └── ViewBuilderGuide.md
│   │       ├── Core/                         # Core protocols
│   │       ├── Views/                        # View implementations
│   │       ├── Modifiers/                    # View modifiers
│   │       └── Encoding/                     # JSON encoding
│   │
│   ├── ClientUI/                              # Client-side renderer
│   │   ├── Package.swift
│   │   └── Sources/ClientUI/
│   │       ├── ClientUI.docc/                 # API documentation
│   │       │   ├── ClientUI.md               # Overview
│   │       │   └── Articles/                 # Guides
│   │       │       ├── GettingStarted.md
│   │       │       ├── RemoteConfiguration.md
│   │       │       ├── PathNavigation.md
│   │       │       └── Logging.md
│   │       ├── Remote/                       # HTTP/networking
│   │       └── Rendering/                    # SwiftUI rendering
│   │
│   └── ViewSchema/                            # Shared JSON schema
│       ├── Package.swift
│       └── Sources/ViewSchema/
│           ├── ViewSchema.docc/               # API documentation
│           │   └── ViewSchema.md             # Overview
│           ├── Core/                         # Core types
│           └── Specs/                        # Specifications
│
└── Samples/                                   # Example apps
    ├── ServerApp/                            # Sample server
    │   ├── Package.swift
    │   └── Sources/ServerApp/
    │       ├── Handlers/                     # Route handlers
    │       ├── HTTP/                         # HTTP server
    │       ├── Routing/                      # Request routing
    │       └── Server/                       # Server bootstrap
    │
    └── iOSClient/                            # Sample iOS app
        └── iOSClient/
            └── iOSClientApp.swift            # Main app
```

## Package Organization

### ServerUI (Server-Side API)

**Purpose**: Provides SwiftUI-like API for defining views on the server.

**Key Components**:
- `Core/` - View protocol, ViewBuilder, EmptyView
- `Views/` - View implementations (Text, VStack, HStack, Navigation)
- `Modifiers/` - View modifiers (font, padding, frame)
- `Encoding/` - Converts views to JSON

**Documentation**: `ServerUI.docc/` contains API docs and conceptual guides.

### ClientUI (Client-Side Renderer)

**Purpose**: Fetches JSON from server and renders with native SwiftUI.

**Key Components**:
- `Remote/` - HTTP networking, configuration, path navigation
- `Rendering/` - ViewRenderer, modifier application, type conversions

**Documentation**: `ClientUI.docc/` contains API docs and usage guides.

### ViewSchema (Shared Schema)

**Purpose**: Defines the JSON schema for view serialization.

**Key Components**:
- `Core/` - ViewHierarchy, ViewNode, ViewType, Modifier
- `Specs/` - Type-specific specifications (TextSpec, VStackSpec, etc.)

**Documentation**: `ViewSchema.docc/` contains schema documentation.

## Documentation Organization

### API Documentation (`.docc` catalogs)

Located within each package:
- Lives alongside source code
- Built with DocC
- Viewed in Xcode or exported as static HTML
- Contains both API reference and conceptual articles

### Project Documentation (`Documentation/`)

General documentation not tied to specific packages:
- Setup instructions
- Project structure
- Historical notes
- Meta-documentation

### Difference Between Locations

| Location | Purpose | Audience | Format |
|----------|---------|----------|--------|
| `.docc/` | API reference & guides | Developers using the API | DocC |
| `Documentation/` | Project-level docs | Contributors & maintainers | Markdown |
| `README.md` | Project overview | Everyone | Markdown |

## File Naming Conventions

### Swift Files
- PascalCase for types: `Text.swift`, `ViewBuilder.swift`
- Descriptive names: `PathNavigator.swift`, `RemoteConfiguration.swift`

### Documentation Files
- PascalCase for DocC articles: `GettingStarted.md`, `NavigationPatterns.md`
- SCREAMING_SNAKE_CASE for project docs: `DOCUMENTATION.md`, `PROJECT_STRUCTURE.md`

### Folders
- PascalCase: `Sources/`, `ClientUI/`, `ProjectGuides/`
- lowercase for standard: `docs/`, `.docc/`

## Build Artifacts

### .build/
Swift Package Manager build artifacts (git-ignored)

### DerivedData/
Xcode build artifacts (git-ignored)

### *.doccarchive
Generated documentation bundles (can be hosted or previewed)

## Workspace Organization

### ServerUI.xcworkspace
Xcode workspace containing all packages for development.

### Individual Package.swift files
Each package is independently buildable with Swift Package Manager.

## Best Practices

### Adding New Code

1. **New View**: Add to `Packages/ServerUI/Sources/ServerUI/Views/`
2. **New Spec**: Add to `Packages/ViewSchema/Sources/ViewSchema/Specs/`
3. **New Renderer**: Add to `Packages/ClientUI/Sources/ClientUI/Rendering/`

### Adding Documentation

1. **API docs**: Add inline `///` comments in source files
2. **Articles**: Add `.md` files to appropriate `.docc/Articles/` folder
3. **Project docs**: Add to `Documentation/` or `Documentation/ProjectGuides/`

### Testing Changes

1. Build individual packages: `cd Packages/[Package] && swift build`
2. Build documentation: `xcodebuild docbuild -scheme [Package]`
3. Run sample apps: Open workspace and run schemes

## Navigation

- **Quick Start**: See `README.md`
- **API Reference**: Build documentation in Xcode
- **Architecture**: See `Documentation/ProjectGuides/ARCHITECTURE.md`
- **Setup Guide**: See `Documentation/DOCUMENTATION.md`
- **This Document**: You are here! 📍

## See Also

- [README.md](../README.md) - Project overview
- [DOCUMENTATION.md](DOCUMENTATION.md) - Documentation guide
- [DOCC_SETUP.md](DOCC_SETUP.md) - DocC setup details

