import SwiftUI
import ViewSchema
import Logging

/// A navigation link that fetches its destination on-demand from a server path.
///
/// This view handles the asynchronous fetching and navigation for path-based
/// navigation links. When tapped, it fetches the destination view hierarchy
/// from the server and navigates immediately.
struct PathNavigationLink<Label: View>: View {
    let spec: NavigationLinkSpec
    let label: Label
    @Environment(\.pathNavigator) private var pathNavigator
    @Environment(\.navigationPath) private var navigationPath
    @State private var isLoading = false
    @State private var error: Error?
    
    private let logger = Logger(label: "com.serverui.pathnavigationlink")
    
    var body: some View {
        Button {
            Task {
                await fetchAndNavigate()
            }
        } label: {
            HStack {
                label
                if isLoading {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .disabled(isLoading)
        .alert("Navigation Error", isPresented: .constant(error != nil)) {
            Button("OK") {
                error = nil
            }
        } message: {
            if let error {
                Text(error.localizedDescription)
            }
        }
    }
    
    private func fetchAndNavigate() async {
        guard let pathNavigator else {
            logger.warning("PathNavigator not found in environment. Make sure RemoteView is properly configured.")
            return
        }
        
        guard let navigationPath else {
            logger.warning("NavigationPath not found in environment. Make sure NavigationStack is using path-based navigation.")
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let destination = try await pathNavigator.fetch(spec)
            // Push to navigation path immediately after fetching
            navigationPath.append(destination)
        } catch {
            self.error = error
            logger.error("Failed to fetch navigation destination", metadata: ["error": "\(error.localizedDescription)"])
        }
        
        isLoading = false
    }
}

