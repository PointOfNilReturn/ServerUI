import SwiftUI

public struct RemoteView: View {
    public let configuration: RemoteConfiguration
    public init(_ configuration: RemoteConfiguration) {
        self.configuration = configuration
    }

    @State private var viewHierarchy: ViewHierarchy?
    @State private var errorMessage: String?
    private let renderer = RemoteRenderer()

    public var body: some View {
        Group {
            if let viewHierarchy {
                renderer.render(viewHierarchy)
                    .padding()
            } else if let errorMessage {
                VStack(spacing: 8) {
                    Text("Load failed")
                        .bold()
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        Task { await load() }
                    }
                }
                .padding()
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
            let envelope = try JSONDecoder().decode(ViewHierarchyEnvelope.self, from: data)
            await MainActor.run { viewHierarchy = envelope.viewHierarchy; errorMessage = nil }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
}
