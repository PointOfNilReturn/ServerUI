import SwiftUI
import ViewSchema

/// Internal content view that manages ActionExecutor observation.
///
/// This view is separated from `RemoteView` to properly observe the `@Observable`
/// `ActionExecutor` and update the view hierarchy when actions complete.
struct RemoteContentView: View {
    let configuration: RemoteConfiguration
    let sessionId: String
    let viewHierarchy: ViewHierarchy?
    let errorMessage: String?
    let pathNavigator: PathNavigator
    let renderer: ViewRenderer
    let onViewUpdate: (ViewHierarchy) -> Void
    let onRetry: () -> Void
    
    @State private var actionExecutor: ActionExecutor
    
    init(
        configuration: RemoteConfiguration,
        sessionId: String,
        viewHierarchy: ViewHierarchy?,
        errorMessage: String?,
        pathNavigator: PathNavigator,
        renderer: ViewRenderer,
        onViewUpdate: @escaping (ViewHierarchy) -> Void,
        onRetry: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.sessionId = sessionId
        self.viewHierarchy = viewHierarchy
        self.errorMessage = errorMessage
        self.pathNavigator = pathNavigator
        self.renderer = renderer
        self.onViewUpdate = onViewUpdate
        self.onRetry = onRetry
        
        // Create action executor
        _actionExecutor = State(wrappedValue: ActionExecutor(
            configuration: configuration,
            sessionId: sessionId
        ))
    }
    
    var body: some View {
        Group {
            if let viewHierarchy {
                renderer.render(viewHierarchy)
                    .environment(\.pathNavigator, pathNavigator)
                    .environment(\.actionExecutor, actionExecutor)
            } else if let errorMessage {
                ContentUnavailableView {
                    Label("Connection issue", systemImage: "wifi.slash")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Refresh") {
                        onRetry()
                    }
                }
            } else {
                ProgressView("Loading…")
            }
        }
        .onChange(of: actionExecutor.latestViewHierarchy) { _, newHierarchy in
            if let newHierarchy {
                onViewUpdate(newHierarchy)
            }
        }
    }
}

