import SwiftUI
import ViewSchema

/// The main renderer that converts a server-defined view hierarchy into native SwiftUI views.
///
/// `ViewRenderer` is responsible for:
/// - Traversing the view hierarchy tree
/// - Converting view specifications to SwiftUI views
/// - Applying modifiers in the correct order
///
/// ## Usage
///
/// ```swift
/// let renderer = ViewRenderer()
/// let swiftUIView = renderer.render(viewHierarchy)
/// ```
///
/// The renderer recursively processes each `ViewNode`, rendering its content and
/// applying any modifiers specified in the JSON.
///
/// - SeeAlso: `ViewHierarchy`, `ViewNode`
@MainActor
public struct ViewRenderer {
    /// Creates a new view renderer.
    public init() {}

    /// Renders a complete view hierarchy into SwiftUI views.
    ///
    /// This is the main entry point for the renderer. It takes a decoded view hierarchy
    /// from the server and converts it into native SwiftUI views.
    ///
    /// - Parameter viewHierarchy: The view hierarchy to render.
    /// - Returns: A SwiftUI view representing the hierarchy.
    @ViewBuilder
    public func render(_ viewHierarchy: ViewHierarchy) -> some View {
        renderNode(viewHierarchy.root)
    }
    
    /// Renders a single view node, applying its modifiers.
    ///
    /// This method:
    /// 1. Renders the node's content (text, stack, etc.)
    /// 2. Applies any modifiers attached to the node
    ///
    /// - Parameter node: The view node to render.
    /// - Returns: A SwiftUI view with modifiers applied.
    @ViewBuilder
    func renderNode(_ node: ViewNode) -> some View {
        let baseView = renderNodeContent(node)
        
        // Apply modifiers (implemented in Renderer+Modifiers.swift)
        applyModifiers(to: baseView, modifiers: node.modifiers)
    }
    
    /// Renders the content of a view node based on its type.
    ///
    /// This method handles the different view types:
    /// - **Text**: Delegates to `Text(TextSpec)` extension
    /// - **VStack/HStack**: Creates stack containers and recursively renders children
    /// - **Unknown**: Returns EmptyView for forward compatibility
    ///
    /// - Parameter node: The view node whose content should be rendered.
    /// - Returns: A SwiftUI view representing the node's content.
    @ViewBuilder
    private func renderNodeContent(_ node: ViewNode) -> some View {
        switch node.type {
        case .text(let spec):
            // Check if this is a state-bound text that needs optimistic updates
            switch spec {
            case .stateBound(let stateKey, let fallbackValue):
                OptimisticText(stateKey: stateKey, fallbackValue: fallbackValue)
            default:
                // Regular text rendering (handled by Text+Renderer.swift extension)
                Text(spec)
            }
            
        case .vstack(let spec):
            VStack(
                alignment: spec.alignment?.toSwiftUI ?? .center,
                spacing: spec.spacing.map { CGFloat($0) }
            ) {
                ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
                    renderNode(child)
                }
            }
            
        case .hstack(let spec):
            HStack(
                alignment: spec.alignment?.toSwiftUI ?? .center,
                spacing: spec.spacing.map { CGFloat($0) }
            ) {
                ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
                    renderNode(child)
                }
            }
            
        case .navigationStack:
            NavigationStackWithPath(node: node, renderer: self)
            
        case .navigationLink(let spec):
            switch spec {
            case .embedded:
                // Embedded navigation: destination is child[1]
                if node.children.count >= 2 {
                    NavigationLink {
                        renderNode(node.children[1]) // destination
                    } label: {
                        renderNode(node.children[0]) // label
                    }
                } else {
                    EmptyView()
                }
                
            case .absolutePath, .relativePath, .absolutePathWithQuery, .relativePathWithQuery:
                // Path-based navigation: fetch destination on-demand
                if !node.children.isEmpty {
                    PathNavigationLink(spec: spec, label: renderNode(node.children[0]))
                } else {
                    EmptyView()
                }
            }
            
        case .button(let spec):
            // Render button with action support
            if !node.children.isEmpty {
                ActionButton(spec: spec, label: renderNode(node.children[0]))
            } else {
                EmptyView()
            }
            
        case .textField(let spec):
            // Render text field with state binding
            DebouncedTextField(spec: spec)
            
        case .unknown:
            EmptyView()
        }
    }
}
