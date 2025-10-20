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
    let currentPath: String
    let onViewUpdate: (ViewHierarchy) -> Void
    let onRetry: () -> Void
    
    @State private var actionExecutor: ActionExecutor
    @State private var stateUpdater: StateUpdater
    @State private var reactiveCache: ReactiveStateCache
    
    init(
        configuration: RemoteConfiguration,
        sessionId: String,
        viewHierarchy: ViewHierarchy?,
        errorMessage: String?,
        pathNavigator: PathNavigator,
        renderer: ViewRenderer,
        currentPath: String,
        onViewUpdate: @escaping (ViewHierarchy) -> Void,
        onRetry: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.sessionId = sessionId
        self.viewHierarchy = viewHierarchy
        self.errorMessage = errorMessage
        self.pathNavigator = pathNavigator
        self.renderer = renderer
        self.currentPath = currentPath
        self.onViewUpdate = onViewUpdate
        self.onRetry = onRetry
        
        // Create reactive cache and initialize with server state
        let cache = ReactiveStateCache()
        if let viewHierarchy {
            cache.initialize(viewHierarchy.initialState)
        }
        
        // Create state updater with current path
        let updater = StateUpdater(
            configuration: configuration,
            sessionId: sessionId,
            currentPath: currentPath
        )
        
        // Connect cache and updater bidirectionally
        cache.setStateUpdater(updater)
        updater.reactiveCache = cache
        
        // Create action executor with current path
        let executor = ActionExecutor(
            configuration: configuration,
            sessionId: sessionId
        )
        executor.currentPath = currentPath
        
        // Inject cache into executor for optimistic updates
        executor.optimisticStateCache = cache
        
        _actionExecutor = State(wrappedValue: executor)
        _stateUpdater = State(wrappedValue: updater)
        _reactiveCache = State(wrappedValue: cache)
    }
    
    var body: some View {
        Group {
            if let viewHierarchy {
                renderer.render(viewHierarchy)
                    .environment(\.pathNavigator, pathNavigator)
                    .environment(\.actionExecutor, actionExecutor)
                    .environment(\.stateUpdater, stateUpdater)
                    .environment(\.reactiveStateCache, reactiveCache)
                    .transaction { transaction in
                        transaction.animation = nil
                        transaction.disablesAnimations = true
                    }
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
        .onChange(of: viewHierarchy) { _, newHierarchy in
            // Reinitialize cache when hierarchy changes
            if let newHierarchy {
                reactiveCache.initialize(newHierarchy.initialState)
            }
        }
        .onChange(of: actionExecutor.latestViewHierarchy) { _, newHierarchy in
            if let newHierarchy {
                // Update cache with new state
                reactiveCache.initialize(newHierarchy.initialState)
                onViewUpdate(newHierarchy)
            }
        }
        .onChange(of: stateUpdater.latestViewHierarchy) { _, newHierarchy in
            if let newHierarchy {
                // Update cache with new state
                reactiveCache.initialize(newHierarchy.initialState)
                onViewUpdate(newHierarchy)
            }
        }
    }
}

