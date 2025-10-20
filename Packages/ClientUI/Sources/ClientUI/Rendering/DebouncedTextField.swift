import SwiftUI
import ViewSchema
import Logging

/// A client-side text field that syncs with server state via the reactive cache.
///
/// `DebouncedTextField` renders a SwiftUI TextField that binds directly to the
/// `ReactiveStateCache`. All synchronization is handled by the cache:
///
/// 1. User types → cache updates immediately (instant UI update)
/// 2. Cache debounces and syncs to server
/// 3. Server response updates cache → all views refresh
///
/// ## Usage
///
/// `DebouncedTextField` is typically not used directly. Instead, it's created automatically
/// by the renderer when it encounters a text field specification.
///
/// ```swift
/// // In Renderer.swift
/// case .textField(let spec):
///     DebouncedTextField(spec: spec)
/// ```
///
/// - SeeAlso: `TextFieldSpec`, `ReactiveStateCache`, ServerUI's `TextField`
struct DebouncedTextField: View {
    /// The text field specification from the server.
    let spec: TextFieldSpec
    
    /// Reactive state cache for instant updates and server sync.
    @Environment(\.reactiveStateCache) private var reactiveCache
    
    var body: some View {
        // Simply bind to the cache - it handles everything!
        TextField(
            spec.prompt,
            text: reactiveCache?.binding(for: spec.stateKey) ?? .constant(spec.currentValue)
        )
        .id(spec.stateKey)
    }
}

