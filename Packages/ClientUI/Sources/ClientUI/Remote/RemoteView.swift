import SwiftUI

public struct RemoteView: View {
    public let url: URL
    public init(url: URL) { self.url = url }

    @State private var remoteRoot: RemoteRoot?
    @State private var errorMessage: String?
    private let renderer = RemoteRenderer()

    public var body: some View {
        Group {
            if let remoteRoot {
                renderer.render(remoteRoot.root)
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
        .task { await load() }
    }

    private func load() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let screen = try JSONDecoder().decode(RemoteRoot.self, from: data)
            await MainActor.run { self.remoteRoot = screen; errorMessage = nil }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
}
