import SwiftUI
import ViewSchema

public struct RemoteView: View {
    public let configuration: RemoteConfiguration
    public init(_ configuration: RemoteConfiguration) {
        self.configuration = configuration
    }

    @State private var viewHierarchy: ViewHierarchy?
    @State private var errorMessage: String?
    private let renderer = ViewRenderer()

    public var body: some View {
        Group {
            if let viewHierarchy {
                renderer.render(viewHierarchy)
                    .padding()
            } else if let errorMessage {
                ContentUnavailableView {
                    Label("Connection issue", systemImage: "wifi.slash")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Refresh") {
                        Task { await load() }
                    }
                }
            } else {
                ProgressView("Loading…")
            }
        }
        .task { await start() }
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
            for (k, v) in configuration.headersProvider() { req.setValue(v, forHTTPHeaderField: k) }

            let (data, _) = try await configuration.session.data(for: req)
            let viewHierarchyEnvelope = try JSONDecoder().decode(ViewHierarchyEnvelope.self, from: data)
            await MainActor.run { viewHierarchy = viewHierarchyEnvelope.viewHierarchy; errorMessage = nil }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
}
