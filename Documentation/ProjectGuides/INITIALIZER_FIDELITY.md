# Initializer Fidelity in ServerUI

## Overview

ServerUI preserves **which initializer** was used to create a view, not just the resulting data. This ensures that the server's intent is accurately reflected when the view is rendered on the client.

## Why This Matters

Consider SwiftUI's `Text` view, which has multiple initializers with different behaviors:

```swift
Text("greeting.hello")           // Localizable - looks up in .strings files
Text(verbatim: "©2024 Acme")     // Literal - renders as-is, no localization
Text(attributedString)           // Rich text with formatting
Text(date, style: .relative)     // Date formatting
```

If we only stored "the string", we'd lose critical information:
- Should "greeting.hello" be localized or displayed literally?
- Is this plain text or attributed text?
- Should dates be formatted on client or server?

## Implementation Pattern

### 1. Spec Enum with Cases Per Initializer

Each initializer variant becomes a separate enum case in the Spec:

```swift
// In ViewSchema
public enum TextSpec: Codable, Sendable, Equatable {
    case localized(String)              // Text("key")
    case verbatim(String)               // Text(verbatim: "literal")
    case attributed(AttributedStringData) // Text(attributedString)
    case date(Date, DateStyle)          // Text(date, style:)
}
```

### 2. Corresponding Initializers in ServerUI

Create matching initializers in the ServerUI view:

```swift
// In ServerUI
public struct Text: View {
    public let spec: TextSpec
    
    // Default initializer - localized
    public init(_ content: String) {
        spec = .localized(content)
    }
    
    // Verbatim initializer
    public init(verbatim content: String) {
        spec = .verbatim(content)
    }
    
    // Future: attributed text
    // public init(_ attributedString: AttributedString) {
    //     spec = .attributed(AttributedStringData(from: attributedString))
    // }
}
```

### 3. Client-Side Rendering

The client renderer switches on the spec case and calls the corresponding SwiftUI initializer:

```swift
// In ClientUI
extension Text {
    init(_ spec: TextSpec) {
        switch spec {
        case .localized(let string):
            self.init(LocalizedStringKey(string))
            
        case .verbatim(let string):
            self.init(verbatim: string)
            
        case .attributed(let data):
            self.init(AttributedString(from: data))
            
        case .date(let date, let style):
            self.init(date, style: style.toSwiftUI)
        }
    }
}
```

## Example: Text Initializers

### Server Code

```swift
import ServerUI

struct ProfileView: View {
    var body: some View {
        VStack {
            // Localized text - will look up "profile.title" in client's .strings
            Text("profile.title")
                .font(.largeTitle)
            
            // Verbatim text - rendered exactly as-is
            Text(verbatim: "©2024 Acme Corporation")
                .font(.caption)
        }
    }
}
```

### Encoded JSON

```json
{
  "children": [
    {
      "type": {
        "text": {
          "_0": {
            "localized": {
              "_0": "profile.title"
            }
          }
        }
      }
    },
    {
      "type": {
        "text": {
          "_0": {
            "verbatim": {
              "_0": "©2024 Acme Corporation"
            }
          }
        }
      }
    }
  ]
}
```

### Client Rendering

```swift
// First text becomes:
Text(LocalizedStringKey("profile.title"))
// Looks up in Localizable.strings:
// "profile.title" = "Profile";

// Second text becomes:
Text(verbatim: "©2024 Acme Corporation")
// Rendered literally, no localization
```

## Benefits

### 1. Localization Support

The client can properly localize strings marked as `.localized`:

```swift
// Server defines:
Text("greeting.hello")

// Client in English: "Hello"
// Client in Spanish: "Hola"
// Client in Japanese: "こんにちは"
```

### 2. Type Safety

Different initializers may have different constraints:

```swift
public enum ButtonSpec {
    case action(label: String, actionID: String)
    case link(label: String, url: URL)
    case role(label: String, role: ButtonRole)
}

// Server:
Button("Cancel", role: .cancel)  // → .role("Cancel", .cancel)
Button(action: { }) { Text("OK") } // → .action with actionID
```

### 3. Future-Proofing

New SwiftUI initializers can be added as new enum cases without breaking existing code:

```swift
// SwiftUI adds new initializer in iOS 18
// Text(_ markdown: String, options: MarkdownOptions)

// Add new case:
public enum TextSpec {
    case localized(String)
    case verbatim(String)
    case markdown(String, MarkdownOptions) // New!
}
```

### 4. Platform-Specific Behavior

Some initializers have platform-specific rendering:

```swift
// Server:
Text(Date(), style: .relative)

// iOS client renders: "2 minutes ago"
// macOS client renders: "2m"
// Different platforms, consistent intent
```

## Applying to Other Views

### Button Initializers

```swift
public enum ButtonSpec {
    case label(String)                    // Button("Title") { }
    case titleKey(String)                 // Button(LocalizedStringKey) { }
    case roleAction(String, ButtonRole)   // Button("Cancel", role: .cancel) { }
}
```

### Image Initializers

```swift
public enum ImageSpec {
    case systemName(String)               // Image(systemName: "star")
    case named(String, Bundle?)           // Image("logo")
    case decorative(systemName: String)   // Image(decorative: "icon")
    case data(Data)                       // Image(data: pngData)
}
```

### Toggle Initializers

```swift
public enum ToggleSpec {
    case binding(label: String, isOn: Bool)     // Toggle("WiFi", isOn: $wifi)
    case sources(label: String, sources: [Bool]) // Toggle("All", sources:)
}
```

## Best Practices

### 1. Document the Mapping

Always document which SwiftUI initializer each spec case corresponds to:

```swift
/// Specification for a Text view, preserving which initializer was used.
///
/// ## Initializer Mapping
///
/// - `.localized(_)` → `Text(_ content: LocalizedStringKey)`
/// - `.verbatim(_)` → `Text(verbatim content: String)`
/// - `.attributed(_)` → `Text(_ attributedString: AttributedString)`
public enum TextSpec: Codable, Sendable, Equatable {
    // ...
}
```

### 2. Name Cases After Behavior, Not Parameters

```swift
// ✅ Good - describes what it does
case localized(String)
case verbatim(String)

// ❌ Bad - just describes the type
case string(String)
case string2(String)
```

### 3. Handle All Cases on Client

Make sure the client renderer handles every spec case:

```swift
extension Text {
    init(_ spec: TextSpec) {
        switch spec {
        case .localized(let string):
            self.init(LocalizedStringKey(string))
        case .verbatim(let string):
            self.init(verbatim: string)
        // ⚠️ Compiler warns if you forget a case!
        }
    }
}
```

### 4. Use Descriptive Associated Values

```swift
// ✅ Good - clear what each value is
case date(Date, style: DateStyle)

// ❌ Bad - unclear what values mean
case date(Date, Int)
```

## Testing

Always test that the correct initializer is called:

```swift
func testTextLocalized() throws {
    let view = Text("greeting")
    let json = try ServerUIJSON.encode(view)
    let decoded = try JSONDecoder().decode(ViewHierarchyEnvelope.self, from: json)
    
    guard case .text(.localized(let string)) = decoded.viewHierarchy.root.type else {
        XCTFail("Expected localized text")
        return
    }
    XCTAssertEqual(string, "greeting")
}

func testTextVerbatim() throws {
    let view = Text(verbatim: "literal")
    let json = try ServerUIJSON.encode(view)
    let decoded = try JSONDecoder().decode(ViewHierarchyEnvelope.self, from: json)
    
    guard case .text(.verbatim(let string)) = decoded.viewHierarchy.root.type else {
        XCTFail("Expected verbatim text")
        return
    }
    XCTAssertEqual(string, "literal")
}
```

## Common Pitfalls

### ❌ Pitfall 1: Treating All Strings the Same

```swift
// Wrong: loses initializer information
public enum TextSpec {
    case string(String) // Which initializer was this?
}
```

### ❌ Pitfall 2: Server-Side Processing

```swift
// Wrong: server shouldn't localize; client should
public init(_ key: String) {
    let localized = NSLocalizedString(key, comment: "")
    spec = .string(localized) // ❌ Already localized!
}
```

### ❌ Pitfall 3: Ignoring Spec on Client

```swift
// Wrong: ignores the spec's intent
extension Text {
    init(_ spec: TextSpec) {
        // ❌ Always treats as verbatim
        self.init(verbatim: spec.someString)
    }
}
```

## Summary

Initializer fidelity ensures that:
1. ✅ The server's intent is preserved
2. ✅ The client renders correctly
3. ✅ Localization works properly
4. ✅ Platform-specific behavior is maintained
5. ✅ The API is future-proof

By encoding **how** a view was created, not just **what** data it contains, ServerUI maintains full compatibility with SwiftUI's rich API surface.

---

*Last updated: 2024*

