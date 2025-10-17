# Navigation Patterns in ServerUI

## Critical Rule: Avoid Nested NavigationStacks

### ❌ Wrong Pattern (Causes Issues)

```swift
// Root screen
struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            NavigationLink("Profile", absolutePath: "/screen/profile")
        }
    }
}

// Destination screen (WRONG!)
struct ProfileScreen: View {
    var body: some View {
        NavigationStack {  // ❌ Creates nested NavigationStack
            VStack {
                Text("Profile")
            }
        }
    }
}
```

**Problem**: This creates `NavigationStack` inside `NavigationStack`, which causes:
- Immediate pop back to previous screen
- Navigation errors and state conflicts
- Broken back button behavior

### ✅ Correct Pattern

```swift
// Root screen - Only one NavigationStack at the top
struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("Profile", absolutePath: "/screen/profile")
            }
            .navigationTitle("Home")
        }
    }
}

// Destination screen - NO NavigationStack wrapper
struct ProfileScreen: View {
    var body: some View {
        VStack {  // ✅ Just the content
            Text("Profile")
        }
        .navigationTitle("Profile")  // Modifiers are fine
    }
}
```

## When to Use NavigationStack

### Root Screens (Entry Points)
Use `NavigationStack` only for:
- Initial/home screen
- Tab views
- Modal presentations
- Any screen that is the **root** of a navigation hierarchy

```swift
// Root screen handler
struct HomeScreenHandler {
    static func response() -> Data {
        ServerUIJSON.encode(HomeScreen())  // Contains NavigationStack
    }
}

private struct HomeScreen: View {
    var body: some View {
        NavigationStack {  // ✅ Root level
            // content
        }
    }
}
```

### Destination Screens (Pushed Views)
**NEVER** wrap in `NavigationStack`:

```swift
// Destination handler
struct ProfileScreenHandler {
    static func response() -> Data {
        ServerUIJSON.encode(ProfileScreen())  // NO NavigationStack
    }
}

private struct ProfileScreen: View {
    var body: some View {
        VStack {  // ✅ Just content
            // content
        }
        .navigationTitle("Profile")  // Modifiers work fine
    }
}
```

## Navigation Types

### Embedded Navigation
Both screens can have NavigationStack because they're not nested:

```swift
// Home screen
NavigationStack {
    NavigationLink("Details") {
        DetailView()  // Embedded, no NavigationStack needed
    }
}

// DetailView content is inline, never has its own NavigationStack
```

### Path-Based Navigation
Only root screen has NavigationStack:

```swift
// Root screen
NavigationStack {  // ✅ One NavigationStack
    NavigationLink("Profile", absolutePath: "/screen/profile")
}

// Destination fetched from server
struct ProfileScreen: View {
    var body: some View {
        VStack { ... }  // ✅ No NavigationStack
    }
}
```

## Common Mistakes to Avoid

### ❌ Mistake 1: Copy-Paste NavigationStack
```swift
// Don't copy the NavigationStack wrapper to every screen
struct EveryScreen: View {
    var body: some View {
        NavigationStack {  // ❌ BAD if this is a destination
            // content
        }
    }
}
```

### ❌ Mistake 2: Wrapping in Response Handler
```swift
static func response() -> Data {
    // ❌ DON'T add NavigationStack here for destinations
    ServerUIJSON.encode(
        NavigationStack { DestinationView() }
    )
}
```

### ✅ Solution: Check Your Navigation Hierarchy
Ask yourself: **"Is this view going to be pushed onto an existing navigation stack?"**
- **Yes** → Don't use NavigationStack
- **No (it's the root)** → Use NavigationStack

## Testing Your Navigation

### Good Signs ✅
- Single tap navigates
- Back button works
- Can navigate multiple levels deep
- Navigation bar appears correctly

### Bad Signs ❌
- Double tap required
- Immediate pop back after navigation
- "Navigation Error" alerts
- Back button missing or broken
- Navigation bar disappears

If you see bad signs, check for nested NavigationStacks!

## Quick Reference

| Screen Type | Use NavigationStack? | Example |
|------------|---------------------|---------|
| Home/Root | ✅ Yes | `NavigationStack { content }` |
| Tab Root | ✅ Yes | Each tab has its own stack |
| Modal Root | ✅ Yes | Modals are separate hierarchies |
| Pushed Screen | ❌ No | Just content + modifiers |
| Linked Screen | ❌ No | Just content + modifiers |
| Detail View | ❌ No | Just content + modifiers |

## Summary

**Golden Rule**: Only the **root** of a navigation hierarchy should have `NavigationStack`. All destinations that are pushed onto that stack should be just plain views with modifiers.

This pattern works for both embedded and path-based navigation!

