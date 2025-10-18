# ViewBuilder Guide

Understand how to compose views with @ViewBuilder.

## Overview

ServerUI uses ``ViewBuilder`` to enable declarative view composition, just like SwiftUI. This guide explains how it works and what you can do with it.

## Basic Usage

Use ``ViewBuilder`` to compose multiple views:

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Title")
            Text("Subtitle")
            Text("Footer")
        }
    }
}
```

The `@ViewBuilder` attribute on the `VStack` initializer lets you write multiple views without array syntax.

## Supported Features

### Multiple Children (Unlimited)

Thanks to parameter packs, you can have any number of children:

```swift
VStack {
    Text("Line 1")
    Text("Line 2")
    Text("Line 3")
    // ... as many as you need
}
```

### Conditional Content

Use `if` statements:

```swift
VStack {
    Text("Always visible")
    
    if isLoggedIn {
        Text("Welcome back!")
    }
}
```

### If-Else

```swift
VStack {
    if isPremium {
        Text("Premium Features")
    } else {
        Text("Standard Features")
    }
}
```

### Loops

Use `ForEach` (when implemented) or manual repetition:

```swift
VStack {
    Text("Item 1")
    Text("Item 2")
    Text("Item 3")
}
```

### Optional Views

```swift
VStack {
    Text("Title")
    optionalSubtitle  // Only included if non-nil
}

var optionalSubtitle: Text? {
    showSubtitle ? Text("Subtitle") : nil
}
```

## How It Works

### Result Builder

``ViewBuilder`` is a `@resultBuilder` that transforms your view code:

```swift
// You write:
VStack {
    Text("A")
    Text("B")
}

// It becomes:
VStack(content: {
    ViewBuilder.buildBlock(Text("A"), Text("B"))
})
```

### TupleView

Multiple children are wrapped in a `TupleView`:

```swift
TupleView<(Text, Text, Text)>
```

This preserves type information while allowing unlimited children via parameter packs.

### Conditional Content

`if-else` statements create `_ConditionalContent`:

```swift
_ConditionalContent<TrueView, FalseView>
```

## Best Practices

### Keep It Simple

✅ **Do:**
```swift
VStack {
    Text("Clear")
    Text("Simple")
}
```

❌ **Don't:**
```swift
VStack {
    // Complex logic here makes the view hard to understand
    if condition1 && condition2 || condition3 {
        if anotherCondition {
            // Too nested
        }
    }
}
```

### Extract Complex Views

✅ **Do:**
```swift
VStack {
    HeaderView()
    ContentView()
    FooterView()
}
```

❌ **Don't:**
```swift
VStack {
    // 50 lines of inline view code
    // ...
}
```

### Use Computed Properties

For conditional content:

```swift
var body: some View {
    VStack {
        Text("Title")
        statusText
    }
}

@ViewBuilder
var statusText: some View {
    if isOnline {
        Text("Connected")
    } else {
        Text("Offline")
    }
}
```

## Limitations

### No Early Returns

❌ This doesn't work:
```swift
var body: some View {
    if condition {
        return Text("A")
    }
    return Text("B")
}
```

✅ Use this instead:
```swift
var body: some View {
    if condition {
        Text("A")
    } else {
        Text("B")
    }
}
```

### No Imperative Code

❌ This doesn't work:
```swift
VStack {
    let x = calculate()  // Can't declare variables
    Text("Result: \(x)")
}
```

✅ Use computed properties:
```swift
var calculatedValue: Int {
    calculate()
}

var body: some View {
    VStack {
        Text("Result: \(calculatedValue)")
    }
}
```

## Advanced Patterns

### Custom @ViewBuilder Functions

```swift
@ViewBuilder
func buildRow(title: String, value: String) -> some View {
    HStack {
        Text(title)
            .font(.headline)
        Text(value)
            .font(.body)
    }
}

// Use it:
VStack {
    buildRow(title: "Name", value: "John")
    buildRow(title: "Email", value: "john@example.com")
}
```

### Generic @ViewBuilder Functions

```swift
@ViewBuilder
func section<Content: View>(
    title: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack {
        Text(title)
            .font(.headline)
        content()
    }
}

// Use it:
section(title: "Profile") {
    Text("Name: John")
    Text("Age: 30")
}
```

## See Also

- ``ViewBuilder``
- ``TupleView``
- <doc:GettingStarted>

