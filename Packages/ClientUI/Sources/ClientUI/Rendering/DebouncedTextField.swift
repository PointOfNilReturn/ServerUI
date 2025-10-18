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
    
    /// Local text value for immediate updates.
    @State private var localText: String = ""
    
    /// State updater for sending changes to the server.
    @Environment(\.stateUpdater) private var stateUpdater
    
    /// Optimistic state cache for instant updates.
    @Environment(\.optimisticStateCache) private var optimisticCache
    
    /// Flag to track if we've initialized the local text.
    @State private var hasInitialized = false
    
    private let logger = Logger(label: "com.serverui.debouncedtextfield")
    
    var body: some View {
        SwiftUI.TextField(spec.prompt, text: $localText)
            .id(spec.stateKey)  // Preserve identity across view updates
            .onChange(of: localText) { _, newValue in
                guard hasInitialized else { return }
                sendUpdate(newValue)
            }
            .onAppear {
                // TODO: We could fetch the initial value from the server
                // For now, text fields start empty
                hasInitialized = true
            }
    }
    
    /// Sends the text update to the server via StateUpdater.
    private func sendUpdate(_ value: String) {
        // Update optimistic cache IMMEDIATELY for instant UI updates
        optimisticCache?.set(stateKey: spec.stateKey, value: value)
        
        // Then send to server (debounced)
        guard let stateUpdater else {
            logger.warning("StateUpdater not found in environment. Text field updates will not sync.")
            return
        }
        
        stateUpdater.updateState(spec.stateKey, value: value)
    }
}

