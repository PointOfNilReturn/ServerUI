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
    @State private var previousPathCount = 0
    @Environment(\.actionExecutor) private var actionExecutor
    @Environment(\.optimisticStateCache) private var optimisticCache
    
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
        .onAppear {
            // Inject the navigation path holder and optimistic cache into the action executor
            actionExecutor?.navigationPathHolder = pathHolder
            actionExecutor?.optimisticStateCache = optimisticCache
            previousPathCount = pathHolder.path.count
        }
        .onChange(of: pathHolder.path.count) { oldCount, newCount in
            // Detect when views are popped (path count decreased)
            if newCount < oldCount {
                let poppedCount = oldCount - newCount
                // Notify server that views were popped (cleanup will be handled server-side)
                // For now, just track the count change
                previousPathCount = newCount
            }
        }
    }
}

