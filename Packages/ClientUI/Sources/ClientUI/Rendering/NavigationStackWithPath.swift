import SwiftUI
import ViewSchema

/// A wrapper around NavigationStack that supports programmatic navigation via NavigationPath.
///
/// This view creates a NavigationPathHolder and injects it into the environment,
/// allowing PathNavigationLink to push destinations after fetching them from the server.
struct NavigationStackWithPath: View {
    let node: ViewNode
    let renderer: ViewRenderer
    
    @State private var pathHolder = NavigationPathHolder()
    
    var body: some View {
        NavigationStack(path: $pathHolder.path) {
            // Render the children of the NavigationStack
            ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
                renderer.renderNode(child)
            }
            .navigationDestination(for: ViewHierarchy.self) { hierarchy in
                // When a ViewHierarchy is pushed to the path, render it
                renderer.render(hierarchy)
            }
        }
        .environment(\.navigationPath, pathHolder)
    }
}

