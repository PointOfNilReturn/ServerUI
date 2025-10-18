import SwiftUI
import ViewSchema
import Logging

/// A client-side text field that syncs with server state.
///
/// `DebouncedTextField` renders a SwiftUI TextField and handles the synchronization
/// with server-side @State variables:
///
/// 1. User types → local text updates immediately (optimistic)
/// 2. After debounce delay → sends update to server
/// 3. Server updates @State variable
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
/// - SeeAlso: `TextFieldSpec`, `StateUpdater`, ServerUI's `TextField`
struct DebouncedTextField: View {
    /// The text field specification from the server.
    let spec: TextFieldSpec
    
    /// State updater for sending changes to the server.
    @Environment(\.stateUpdater) private var stateUpdater
    
    /// Optimistic state cache for instant updates.
    @Environment(\.optimisticStateCache) private var optimisticCache
    
    private let logger = Logger(label: "com.serverui.debouncedtextfield")
    
    var body: some View {
        // Always read from cache if available, otherwise from server
        let displayValue = optimisticCache?.get(stateKey: spec.stateKey) ?? spec.currentValue
        
        TextField(spec.prompt, text: Binding(
            get: { displayValue },
            set: { newValue in
                // Update cache immediately for instant UI
                optimisticCache?.set(stateKey: spec.stateKey, value: newValue)
                
                // Send to server (debounced)
                stateUpdater?.updateState(spec.stateKey, value: newValue)
            }
        ))
        .id(spec.stateKey)
    }
}

