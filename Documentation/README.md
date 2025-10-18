# ServerUI Documentation

This folder contains project-level documentation and guides.

## Documentation Structure

### DocC Catalogs (API Documentation)

API documentation lives with the code in `.docc` catalogs:

- `Packages/ServerUI/Sources/ServerUI/ServerUI.docc/` - Server-side API
- `Packages/ClientUI/Sources/ClientUI/ClientUI.docc/` - Client-side API
- `Packages/ViewSchema/Sources/ViewSchema/ViewSchema.docc/` - JSON schema

### Project Guides

General documentation and guides:

- `DOCUMENTATION.md` - How to build and view docs
- `DOCC_SETUP.md` - DocC setup summary

### Historical/Reference Guides

These articles have been integrated into DocC but are kept for reference:

- `ProjectGuides/ARCHITECTURE.md` → Now in `ServerUI.docc/Articles/Architecture.md`
- `ProjectGuides/NAVIGATION_PATTERNS.md` → Now in `ServerUI.docc/Articles/NavigationPatterns.md`
- `ProjectGuides/PATH_NAVIGATION.md` → Now in `ServerUI.docc/Articles/PathNavigation.md`
- `ProjectGuides/INITIALIZER_FIDELITY.md` → Now in `ServerUI.docc/Articles/InitializerFidelity.md`
- `ProjectGuides/LOGGING.md` → Now in `ClientUI.docc/Articles/Logging.md`
- `ProjectGuides/SINGLE_TAP_NAVIGATION_FIX.md` - Technical implementation notes

## Viewing Documentation

### In Xcode

1. Open `ServerUI.xcworkspace`
2. Select a scheme (ServerUI, ClientUI, or ViewSchema)
3. **Product → Build Documentation** (⌃⇧⌘D)

### Quick Help

- ⌥ + Click any symbol for inline documentation
- ⌃⌘? to open Documentation window

### Command Line

```bash
cd Packages/ServerUI
xcodebuild docbuild -scheme ServerUI -destination 'platform=macOS'
```

## Contributing Documentation

### Inline Documentation

Use triple-slash comments in code:

```swift
/// Brief description.
///
/// Detailed explanation.
///
/// - Parameter name: Description
/// - Returns: Description
public func example(name: String) -> Bool { ... }
```

### Articles

Add `.md` files to appropriate `.docc/Articles/` folders:

```
Packages/[Package]/Sources/[Package]/[Package].docc/Articles/
```

Reference articles in the main overview file's Topics section.

## Resources

- [DocC Documentation](https://www.swift.org/documentation/docc/)
- [Writing Symbol Documentation](https://developer.apple.com/documentation/xcode/writing-symbol-documentation-in-your-source-files)
- See `DOCUMENTATION.md` for detailed instructions

