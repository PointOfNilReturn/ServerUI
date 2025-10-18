import SwiftUI
import ViewSchema

public struct RemoteView: View {
    public let configuration: RemoteConfiguration
    
    @State private var viewHierarchy: ViewHierarchy?
    @State private var errorMessage: String?
    @State private var pathNavigator: PathNavigator
    @State private var sessionId: String
    private let renderer = ViewRenderer()

    public init(_ configuration: RemoteConfiguration) {
        self.configuration = configuration
        let sessionId = UUID().uuidString
        _sessionId = State(wrappedValue: sessionId)
        _pathNavigator = State(wrappedValue: PathNavigator(configuration: configuration))
    }

    public var body: some View {
        content
            .task { await start() }
    }
    
    @ViewBuilder
    private var content: some View {
        RemoteContentView(
            configuration: configuration,
            sessionId: sessionId,
            viewHierarchy: viewHierarchy,
            errorMessage: errorMessage,
            pathNavigator: pathNavigator,
            renderer: renderer,
            onViewUpdate: { newHierarchy in
                viewHierarchy = newHierarchy
            },
            onRetry: {
                Task { await load() }
            }
        )
    }
    
    // MARK: - Networking

    private func start() async {
        await load()
        if case .httpPolling(let seconds) = configuration.transport, seconds > .zero {
            while true {
                try? await Task.sleep(for: .seconds(seconds))
                await load()
            }
        }
    }

    private func load(path: String? = nil) async {
        do {
            var req = URLRequest(url: configuration.url)
            req.httpMethod = "GET"
            req.setValue(sessionId, forHTTPHeaderField: "X-Session-ID")
            for (k, v) in configuration.headersProvider() { req.setValue(v, forHTTPHeaderField: k) }

            let (data, _) = try await configuration.session.data(for: req)
            let viewHierarchyEnvelope = try JSONDecoder().decode(ViewHierarchyEnvelope.self, from: data)
            await MainActor.run { viewHierarchy = viewHierarchyEnvelope.viewHierarchy; errorMessage = nil }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
}
