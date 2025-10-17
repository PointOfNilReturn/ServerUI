# Single-Tap Navigation Fix

## Problem

Path-based navigation links required **two taps** to navigate:
1. **First tap**: Fetched JSON from server → Changed from `Button` to `NavigationLink`
2. **Second tap**: Actually navigated to the destination

## Root Cause

The original implementation switched the view type after fetching:
```swift
if let destination {
    NavigationLink { ... } // Rendered after fetch
} else {
    Button { fetchDestination() } // Rendered initially
}
```

This required re-rendering and a second tap on the newly-created `NavigationLink`.

## Solution: Programmatic Navigation

Implemented SwiftUI's modern `NavigationStack(path:)` pattern for programmatic navigation:

### 1. NavigationPathHolder (`@Observable`)
```swift
@Observable
@MainActor
public final class NavigationPathHolder {
    public var path: [ViewHierarchy] = []
    
    public func append(_ hierarchy: ViewHierarchy) {
        path.append(hierarchy)
    }
}
```

### 2. NavigationStackWithPath
Wraps `NavigationStack` and injects the path holder:
```swift
NavigationStack(path: $pathHolder.path) {
    // Content
}
.navigationDestination(for: ViewHierarchy.self) { hierarchy in
    renderer.render(hierarchy)
}
.environment(\.navigationPath, pathHolder)
```

### 3. PathNavigationLink
Now pushes immediately after fetching:
```swift
Button {
    Task {
        let destination = try await pathNavigator.fetch(spec)
        navigationPath.append(destination)  // ← Immediate navigation!
    }
} label: {
    label
}
```

## Changes Made

### ViewSchema
- ✅ Added `Hashable` to `ViewHierarchy`, `ViewNode`, `ViewType`, `Modifier`
- ✅ Added `Hashable` to all Spec types (TextSpec, VStackSpec, etc.)

### ClientUI
- ✅ Created `NavigationPathHolder` - Observable wrapper for navigation path
- ✅ Created `NavigationPathKey` - Environment key for path injection
- ✅ Created `NavigationStackWithPath` - Helper view managing path-based navigation
- ✅ Updated `PathNavigationLink` - Now uses programmatic navigation
- ✅ Updated `Renderer` - Uses `NavigationStackWithPath` for NavigationStack nodes

### Result
✅ **Single-tap navigation** - Fetch and navigate in one tap  
✅ **Loading indicator** - Shows while fetching  
✅ **Error handling** - Shows alert if fetch fails  
✅ **Zero breaking changes** - Embedded navigation still works  

## Technical Details

### Why Hashable?

`NavigationStack(path:)` requires the path type to conform to `Hashable`:
```swift
NavigationStack(path: Binding<[T]>) where T: Hashable
```

Since our path is `[ViewHierarchy]`, we needed to make the entire hierarchy `Hashable`.

### NavigationDestination

SwiftUI's `.navigationDestination(for:)` modifier handles rendering:
```swift
.navigationDestination(for: ViewHierarchy.self) { hierarchy in
    renderer.render(hierarchy)
}
```

When `navigationPath.append(hierarchy)` is called, SwiftUI automatically:
1. Pushes a new view to the navigation stack
2. Calls the closure with the pushed value
3. Renders the returned view

## Testing

Server is running at `http://localhost:8080`

Try tapping these path-based links (all should navigate with **one tap**):
- "Profile (Absolute Path)" → `/screen/profile`
- "Settings (Relative Path)" → `settings`
- "User Details (With Query)" → `/user?id=123`
- "Details (Type-Safe)" → `details`

All now navigate immediately after fetching!

