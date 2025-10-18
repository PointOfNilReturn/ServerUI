# Documentation

ServerUI uses Apple's DocC for comprehensive, searchable documentation.

## Building Documentation

### Using Xcode

1. Open `ServerUI.xcworkspace`
2. Select the scheme you want (ServerUI, ClientUI, or ViewSchema)
3. Choose **Product → Build Documentation** (⌃⇧⌘D)
4. Documentation opens in Xcode's documentation viewer

### Using Command Line

```bash
# Build ServerUI documentation
cd Packages/ServerUI
xcodebuild docbuild -scheme ServerUI -destination 'platform=macOS'

# Build ClientUI documentation  
cd Packages/ClientUI
xcodebuild docbuild -scheme ClientUI -destination 'platform=macOS'

# Build ViewSchema documentation
cd Packages/ViewSchema
xcodebuild docbuild -scheme ViewSchema -destination 'platform=macOS'
```

## Documentation Structure

Each package has its own documentation catalog:

```
Packages/
├── ServerUI/
│   └── Sources/ServerUI/ServerUI.docc/
│       ├── ServerUI.md           # Overview
│       └── Articles/
│           ├── GettingStarted.md
│           ├── Architecture.md
│           ├── NavigationPatterns.md
│           ├── PathNavigation.md
│           ├── InitializerFidelity.md
│           └── ViewBuilderGuide.md
│
├── ClientUI/
│   └── Sources/ClientUI/ClientUI.docc/
│       ├── ClientUI.md           # Overview
│       └── Articles/
│           ├── GettingStarted.md
│           ├── RemoteConfiguration.md
│           ├── PathNavigation.md
│           └── Logging.md
│
└── ViewSchema/
    └── Sources/ViewSchema/ViewSchema.docc/
        └── ViewSchema.md          # Overview
```

## Documentation Content

### ServerUI Documentation

- **Overview**: Server-side view API
- **Getting Started**: First steps
- **Architecture**: System design
- **Navigation Patterns**: Avoid common mistakes
- **Path Navigation**: On-demand fetching
- **Initializer Fidelity**: Advanced Text handling
- **ViewBuilder Guide**: Composing views

### ClientUI Documentation

- **Overview**: Client-side rendering
- **Getting Started**: Basic setup
- **Remote Configuration**: Advanced connection setup
- **Path Navigation**: On-demand navigation
- **Logging**: Debugging and monitoring

### ViewSchema Documentation

- **Overview**: JSON schema definitions
- Core types and specifications

## Viewing Documentation

### In Xcode

Documentation appears in:
- Quick Help (⌥ + Click on any symbol)
- Documentation window (⌃⌘?)
- Code completion
- Jump to Definition

### Exporting

To export static documentation:

```bash
xcodebuild docbuild \
  -scheme ServerUI \
  -destination 'platform=macOS' \
  -derivedDataPath ./docs
```

The generated documentation is in `./docs/Build/Products/Debug/ServerUI.doccarchive`

You can then host this with:
```bash
docc preview ./docs/Build/Products/Debug/ServerUI.doccarchive
```

## Writing Documentation

### Code Comments

Use triple-slash (`///`) for documentation:

```swift
/// Creates a text view with localized content.
///
/// The content string is treated as a localization key and will be
/// looked up in the app's string catalogs.
///
/// - Parameter content: The localization key for the text.
public init(_ content: String) {
    spec = .localized(content)
}
```

### Articles

Articles use Markdown with DocC extensions:

```markdown
# Article Title

Introduction paragraph.

## Section

Content with links to symbols: ``View``, ``Text``, etc.

Links to other articles: <doc:OtherArticle>
```

### Topics

Organize symbols in topic groups:

```markdown
## Topics

### Views

- ``Text``
- ``VStack``
- ``HStack``

### Modifiers

- ``ModifiedContent``
```

## Best Practices

✅ **Do:**
- Write clear, concise summaries
- Provide code examples
- Link to related symbols
- Organize with topic groups
- Document all public APIs

❌ **Don't:**
- Leave public APIs undocumented
- Use vague descriptions
- Forget to update docs when code changes
- Mix documentation styles

## Resources

- [DocC Documentation](https://www.swift.org/documentation/docc/)
- [Writing Documentation](https://developer.apple.com/documentation/xcode/writing-symbol-documentation-in-your-source-files)
- [DocC Syntax](https://developer.apple.com/documentation/docc/formatting-your-documentation-content)

