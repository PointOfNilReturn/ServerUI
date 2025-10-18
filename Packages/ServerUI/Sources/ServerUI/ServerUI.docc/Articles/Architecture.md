# ServerUI Architecture

This document explains the internal architecture of ServerUI for contributors and developers who want to understand how the system works.

## Table of Contents

- [Overview](#overview)
- [Package Structure](#package-structure)
- [Core Concepts](#core-concepts)
- [Encoding Pipeline](#encoding-pipeline)
- [Type Erasure Pattern](#type-erasure-pattern)
- [Parameter Pack Implementation](#parameter-pack-implementation)
- [Adding New Views](#adding-new-views)
- [Adding New Modifiers](#adding-new-modifiers)

## Overview

ServerUI's architecture mirrors SwiftUI's design but adds an encoding layer that converts view hierarchies into JSON. The system is split into three packages for clear separation of concerns:

```
┌────────────────────────────────────────────────────┐
│                    ServerUI                        │
│  (Server-side view DSL & encoding)                 │
│                                                    │
│  • View protocol                                   │
│  • ViewBuilder result builder                     │
│  • Primitive views (Text, VStack, HStack)         │
│  • Encoding engine                                 │
└──────────────────┬─────────────────────────────────┘
                   │ depends on
                   ↓
┌────────────────────────────────────────────────────┐
│                  ViewSchema                        │
│  (Shared JSON schema definitions)                  │
│                                                    │
│  • ViewNode, ViewHierarchy                         │
│  • ViewType enum                                   │
│  • Modifier enum                                   │
│  • Spec types (TextSpec, VStackSpec, etc.)        │
└──────────────────┬─────────────────────────────────┘
                   │ depends on
                   ↑
┌────────────────────────────────────────────────────┐
│                   ClientUI                         │
│  (Client-side JSON decoder & renderer)            │
│                                                    │
│  • RemoteView                                      │
│  • ViewRenderer                                    │
│  • Transport layer (HTTP polling, etc.)           │
└────────────────────────────────────────────────────┘
```

## Package Structure

### ServerUI

```
ServerUI/
├── Core/
│   ├── View.swift              # View protocol, EmptyView
│   ├── ViewBuilder.swift        # Result builder, TupleView, helper views
│   └── ViewModifiers.swift      # ModifiedContent, modifier extensions
├── Primitives/
│   ├── Text.swift              # Text view
│   ├── VStack.swift            # Vertical stack
│   └── HStack.swift            # Horizontal stack
└── Encoding/
    └── Encode.swift            # Engine, protocols, ServerUIJSON
```

### ViewSchema

```
ViewSchema/
├── ViewNode.swift              # Node in the view tree
├── ViewHierarchy.swift         # Root container
├── ViewHierarchyEnvelope.swift # Versioned wrapper
├── ViewType.swift              # Enum of all view types
├── Modifier.swift              # Enum of all modifiers
├── Property.swift              # Generic property type
└── Specs/
    ├── TextSpec.swift          # Text configuration
    ├── VStackSpec.swift        # VStack configuration
    ├── HStackSpec.swift        # HStack configuration
    └── AlignmentSpecs.swift    # Alignment enums
```

### ClientUI

```
ClientUI/
├── Remote/
│   ├── RemoteView.swift        # Main client view
│   └── RemoteConfiguration.swift # Connection settings
└── Render/
    ├── Renderer.swift          # Recursive ViewNode → SwiftUI
    └── TextRenderer.swift      # SwiftUI.Text extension
```

## Core Concepts

### 1. View Protocol

The `View` protocol is the foundation:

```swift
public protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}
```

**Key properties:**
- **Associated type**: Enables type-safe composition
- **ViewBuilder**: Enables multi-statement closures
- **Recursive structure**: Custom views decompose into primitives

**Primitive views** (like `Text`, `VStack`) return `EmptyView` as their body to terminate recursion.

### 2. Result Builder Pattern

`@resultBuilder` transforms multi-line closures into function calls:

```swift
// User writes:
VStack {
    Text("A")
    Text("B")
    Text("C")
}

// Swift transforms to:
VStack(content: {
    ViewBuilder.buildBlock(
        Text("A"),
        Text("B"),
        Text("C")
    )
})
```

The `buildBlock` methods determine the return type based on the number of arguments.

### 3. Type Erasure via Protocols

Because views have complex generic types (e.g., `VStack<TupleView<Text, Text, Text>>`), the encoding engine can't use simple type checks. Instead, we use **protocol-based type erasure**:

```swift
// ❌ Can't do this - we don't know the generic types
if let vstack = view as? VStack<???> { }

// ✅ Can do this - protocol works with any generic type
if let vstack = view as? any VStackProtocol {
    let (spec, content) = vstack.extractVStack()
}
```

## Encoding Pipeline

The encoding process has several stages:

### Stage 1: View Decomposition

Custom views are recursively decomposed via their `body` property:

```swift
struct WelcomeView: View {
    var body: some View {
        VStack {
            Text("Hello")
        }
    }
}

// Engine processes:
WelcomeView → body → VStack<Text> → primitive!
```

### Stage 2: Node Construction

Each primitive view becomes a `ViewNode`:

```swift
ViewNode(
    type: .vstack(VStackSpec(alignment: .center, spacing: nil)),
    children: [
        ViewNode(
            type: .text(TextSpec.string("Hello")),
            children: [],
            modifiers: []
        )
    ],
    modifiers: []
)
```

### Stage 3: Child Collection

Container views (VStack, HStack) need their children extracted. This is where `TupleView` comes in:

```swift
VStack {
    Text("A")
    Text("B")
}

// VStack's content type is: TupleView<Text, Text>
// collectChildren extracts: [Text("A"), Text("B")]
// Maps to: [ViewNode, ViewNode]
```

### Stage 4: Modifier Accumulation

Modifiers wrap views in `ModifiedContent`:

```swift
Text("Hello").font(.title).foregroundColor(.blue)

// Structure:
ModifiedContent<
    ModifiedContent<
        Text,
        font modifier
    >,
    foregroundColor modifier
>
```

The engine unwraps these recursively and accumulates modifiers on the underlying node.

### Stage 5: JSON Serialization

The final `ViewHierarchy` is wrapped in a `ViewHierarchyEnvelope` (for versioning) and encoded to JSON using `JSONEncoder`.

## Type Erasure Pattern

Here's how type erasure works in detail:

### Problem

```swift
// VStack is generic over its content
public struct VStack<Content: View>: View { ... }

// In the encoder, we receive `any View`
func viewNode<Content: View>(from view: Content) -> ViewNode {
    // ❌ Can't cast - don't know what Content type VStack has
    if let vstack = view as? VStack {  // Error: generic type requires arguments
        // ...
    }
}
```

### Solution

1. **Define a protocol:**

```swift
public protocol VStackProtocol {
    func extractVStack() -> (spec: VStackSpec, content: any View)
}
```

2. **Conform the generic type:**

```swift
extension VStack: VStackProtocol {
    public func extractVStack() -> (spec: VStackSpec, content: any View) {
        return (spec, content)  // Type-erased!
    }
}
```

3. **Use existential types:**

```swift
func viewNode<Content: View>(from view: Content) -> ViewNode {
    // ✅ Works with any VStack<T>
    if let vstack = view as? any VStackProtocol {
        let (spec, content) = vstack.extractVStack()
        return ViewNode(
            type: .vstack(spec),
            children: collectChildren(from: content)
        )
    }
}
```

## Parameter Pack Implementation

### The Challenge

SwiftUI's `ViewBuilder` has overloads for 0-10 children:

```swift
public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleView<C0, C1>
public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView<C0, C1, C2>
// ... up to 10 parameters
```

This creates a hard limit of 10 children per container.

### Our Solution: Parameter Packs

Swift 5.9 introduced parameter packs (variadic generics):

```swift
public static func buildBlock<each Content: View>(
    _ content: repeat each Content
) -> TupleView<repeat each Content> {
    TupleView(repeat each content)
}
```

**But there's a problem**: This matches *any* number of arguments, including 0 and 1, creating ambiguity with existing overloads.

### The Fix: Explicit Overloads

We provide explicit overloads for small cases:

```swift
// 0 children
public static func buildBlock() -> EmptyView

// 1 child
public static func buildBlock<Content: View>(_ content: Content) -> Content

// 2 children
public static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1) -> TupleView<C0, C1>

// 3+ children (parameter pack)
public static func buildBlock<C0: View, C1: View, C2: View, each Content: View>(
    _ c0: C0, _ c1: C1, _ c2: C2, _ content: repeat each Content
) -> TupleView<C0, C1, C2, repeat each Content>
```

The 3+ overload requires at least 3 fixed parameters before the pack, ensuring Swift chooses the right overload.

### Extracting Children

Parameter packs can be iterated with `repeat`:

```swift
public func extractChildren() -> [any View] {
    var children: [any View] = []
    repeat children.append(each content)  // Iterate pack!
    return children
}
```

## Adding New Views

To add a new view type (e.g., `Button`):

### 1. Define the Spec (ViewSchema)

```swift
// In ViewSchema/Sources/ViewSchema/Specs/ButtonSpec.swift
public struct ButtonSpec: Codable, Equatable, Sendable {
    public let label: String
    public let actionID: String
    
    public init(label: String, actionID: String) {
        self.label = label
        self.actionID = actionID
    }
}
```

### 2. Add to ViewType Enum

```swift
// In ViewSchema/Sources/ViewSchema/ViewType.swift
public enum ViewType: Codable, Sendable, Equatable {
    case unknown
    case text(TextSpec)
    case vstack(VStackSpec)
    case hstack(HStackSpec)
    case button(ButtonSpec)  // Add this
}
```

### 3. Create the View (ServerUI)

```swift
// In ServerUI/Sources/ServerUI/Primitives/Button.swift
import ViewSchema

public struct Button<Label: View>: View {
    public let spec: ButtonSpec
    public let label: Label
    
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        // Generate a unique action ID
        self.spec = ButtonSpec(label: "", actionID: UUID().uuidString)
        self.label = label()
    }
    
    public var body: EmptyView { EmptyView() }
}

// Protocol for encoding
public protocol ButtonProtocol {
    func extractButton() -> (spec: ButtonSpec, label: any View)
}

extension Button: ButtonProtocol {
    public func extractButton() -> (spec: ButtonSpec, label: any View) {
        return (spec, label)
    }
}
```

### 4. Add Encoding Support

```swift
// In ServerUI/Sources/ServerUI/Encoding/Encode.swift
static func viewNode<Content: View>(from view: Content) -> ViewNode {
    // ... existing code ...
    
    // Add button case
    if let button = view as? any ButtonProtocol {
        let (spec, label) = button.extractButton()
        return ViewNode(
            type: .button(spec),
            children: collectChildren(from: label)
        )
    }
    
    // ... rest of code ...
}
```

### 5. Add Client Rendering (ClientUI)

```swift
// In ClientUI/Sources/ClientUI/Render/Renderer.swift
@ViewBuilder
private func renderNodeContent(_ node: ViewNode) -> some View {
    switch node.type {
    // ... existing cases ...
    
    case .button(let spec):
        Button(action: {
            // Handle action callback
            handleAction(spec.actionID)
        }) {
            // Render label children
            ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
                renderNode(child)
            }
        }
    }
}
```

## Adding New Modifiers

To add a new modifier (e.g., `.padding()`):

### 1. Add to Modifier Enum (ViewSchema)

```swift
// In ViewSchema/Sources/ViewSchema/Modifier.swift
public enum Modifier: Codable, Equatable, Sendable {
    case font(FontRole)
    case padding(PaddingSpec)  // Add this
}

public struct PaddingSpec: Codable, Equatable, Sendable {
    public let edges: EdgeSetSpec?
    public let length: Double?
}
```

### 2. Add View Extension (ServerUI)

```swift
// In ServerUI/Sources/ServerUI/Core/ViewModifiers.swift
public extension View {
    func padding(_ length: Double? = nil) -> ModifiedContent<Self> {
        ModifiedContent(
            content: self,
            modifier: .padding(PaddingSpec(edges: nil, length: length))
        )
    }
}
```

### 3. Add Client Rendering (ClientUI)

```swift
// In ClientUI/Sources/ClientUI/Render/Renderer.swift
@ViewBuilder
private func applyModifiers<V: View>(to view: V, modifiers: [Modifier]) -> some View {
    modifiers.reduce(AnyView(view)) { currentView, modifier in
        switch modifier {
        case .font(let role):
            return AnyView(currentView.font(role.toSwiftUI))
        case .padding(let spec):  // Add this
            if let length = spec.length {
                return AnyView(currentView.padding(CGFloat(length)))
            } else {
                return AnyView(currentView.padding())
            }
        }
    }
}
```

## Best Practices

### 1. Always Use Protocols for Type Erasure

Never try to cast to generic types directly in the encoding engine.

### 2. Keep Specs Simple

Specs should be pure data structures with no logic. They must be `Codable`, `Equatable`, and `Sendable`.

### 3. Test Both Encoding and Decoding

Add tests that verify:
- Views encode to correct JSON
- JSON decodes correctly on the client
- Round-trip encoding/decoding preserves data

### 4. Document Everything

Use DocC-style documentation comments for all public APIs.

### 5. Consider Backwards Compatibility

When modifying the schema, use `schemaVersion` to handle breaking changes gracefully.

## Performance Considerations

### Encoding

- Encoding is O(n) in the number of views
- Type checking with protocols is constant time
- Consider caching encoded results for static views

### Network

- JSON is verbose; consider compression (gzip)
- For frequently changing views, implement delta updates
- Use WebSockets instead of polling for better latency

### Client Rendering

- SwiftUI handles rendering efficiently
- Large lists should use SwiftUI's `List` (TODO: not yet implemented)
- Avoid excessive re-fetching; use appropriate polling intervals

## Debugging Tips

### Enable Encoding Logs

Add print statements to `Engine.viewNode` to trace the encoding process:

```swift
static func viewNode<Content: View>(from view: Content) -> ViewNode {
    print("Encoding: \(type(of: view))")
    // ...
}
```

### Inspect JSON Output

Use `jq` to pretty-print and inspect JSON:

```bash
curl http://localhost:8080/screen/home | jq '.'
```

### Test Individual Views

Create unit tests for encoding:

```swift
func testVStackEncoding() throws {
    let view = VStack {
        Text("A")
        Text("B")
    }
    let json = try ServerUIJSON.encode(view)
    let hierarchy = try JSONDecoder().decode(ViewHierarchyEnvelope.self, from: json)
    
    XCTAssertEqual(hierarchy.viewHierarchy.root.children.count, 2)
}
```

## Further Reading

- [Swift Result Builders](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630)
- [Swift Parameter Packs](https://github.com/apple/swift-evolution/blob/main/proposals/0393-parameter-packs.md)
- [SwiftUI View Protocol](https://developer.apple.com/documentation/swiftui/view)
- [Type Erasure in Swift](https://www.swiftbysundell.com/articles/different-flavors-of-type-erasure-in-swift/)

---

*This document is a living guide. As the architecture evolves, please keep it updated.*

