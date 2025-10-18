import SwiftUI
import ViewSchema
import Logging

/// A client-side button that sends actions to the server when tapped.
///
/// `ActionButton` renders a button from server-defined specifications and handles
/// the action execution flow:
///
/// 1. User taps the button
/// 2. Client sends action request to server with the action ID
/// 3. Server executes the action (mutating @State, etc.)
/// 4. Server responds with updated view hierarchy
/// 5. Client re-renders with the new state
///
/// ## Usage
///
/// `ActionButton` is typically not used directly. Instead, it's created automatically
/// by the renderer when it encounters a button specification.
///
/// ```swift
/// // In Renderer.swift
/// case .button(let spec):
///     ActionButton(spec: spec, label: renderNode(node.children[0]))
/// ```
///
/// - SeeAlso: `ButtonSpec`, `ActionExecutor`, ServerUI's `Button`
struct ActionButton<Label: View>: View {
    /// The button specification from the server.
    let spec: ButtonSpec
    
    /// The button's label view.
    let label: Label
    
    /// Action executor for sending actions to the server.
    @Environment(\.actionExecutor) private var actionExecutor
    
    /// Loading state while action is executing.
    @State private var isExecuting = false
    
    /// Error that occurred during action execution.
    @State private var error: Error?
    
    private let logger = Logger(label: "com.serverui.actionbutton")
    
    var body: some View {
        Button {
            Task { await executeAction() }
        } label: {
            HStack {
                label
                if isExecuting {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .disabled(isExecuting)
        .alert("Action Failed", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            if let error {
                Text(error.localizedDescription)
            }
        }
    }
    
    /// Executes the button's action by sending a request to the server.
    private func executeAction() async {
        guard let actionExecutor else {
            logger.warning("ActionExecutor not found in environment. Button taps will not work.")
            return
        }
        
        isExecuting = true
        error = nil
        
        do {
            try await actionExecutor.execute(spec.actionId)
            logger.debug("Action executed successfully", metadata: ["actionId": "\(spec.actionId)"])
        } catch {
            self.error = error
            logger.error("Action execution failed", metadata: [
                "actionId": "\(spec.actionId)",
                "error": "\(error.localizedDescription)"
            ])
        }
        
        isExecuting = false
    }
}

