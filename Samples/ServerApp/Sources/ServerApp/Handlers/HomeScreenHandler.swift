import Foundation
import ServerUI

private struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                Text("greeting.welcome")
                    .font(.largeTitle)
                    .padding()
                
                Text(verbatim: "ServerUI Navigation Demo")
                    .font(.headline)
                
                // Embedded Navigation (SwiftUI-mirroring)
                Text(verbatim: "Embedded Navigation")
                    .font(.headline)
                    .padding(.top)
                
                VStack(spacing: 12) {
                    NavigationLink("View Modifier Examples") {
                        ModifiersScreen()
                    }
                    
                    NavigationLink("View Text Initializers") {
                        TextInitializersScreen()
                    }
                    
                    NavigationLink("View Layout Examples") {
                        LayoutExamplesScreen()
                    }
                }
                .padding()
                
                // Path-Based Navigation (On-Demand)
                Text(verbatim: "Path-Based Navigation (TODO)")
                    .font(.headline)
                    .padding(.top, 10)
                
                VStack(spacing: 12) {
                    NavigationLink("Profile (Absolute Path)", absolutePath: "/screen/profile")
                    NavigationLink("Settings (Relative Path)", relativePath: "settings")
                    NavigationLink("User Details (With Query)", absolutePath: "/user", query: ["id": "123"])
                    NavigationLink("Details (Type-Safe)", path: .relative("details"))
                }
                .padding()
                
                // Footer
                Text(verbatim: "©2024 ServerUI Project")
                    .font(.caption)
                    .padding(.top, 40)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

// MARK: - Detail Screens

private struct ModifiersScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(verbatim: "Modifier Examples")
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: "Padding:")
                    .font(.headline)
                
                Text(verbatim: "Default padding")
                    .font(.body)
                    .padding()
                
                Text(verbatim: "Custom 20pt padding")
                    .font(.body)
                    .padding(20)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: "Frame:")
                    .font(.headline)
                
                Text(verbatim: "Fixed 200x50")
                    .font(.body)
                    .frame(width: 200, height: 50)
                    .padding(8)
                
                Text(verbatim: "Min width 150")
                    .font(.body)
                    .frame(minWidth: 150)
                    .padding(8)
            }
        }
        .padding()
        .navigationTitle("Modifiers")
    }
}

private struct TextInitializersScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(verbatim: "Text Initializer Examples")
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: "Localized:")
                    .font(.headline)
                Text("greeting.welcome")
                    .font(.body)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: "Verbatim:")
                    .font(.headline)
                Text(verbatim: "©2024 ServerUI")
                    .font(.body)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: "Date Formatting:")
                    .font(.headline)
                Text(Date(), style: .time)
                    .font(.body)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: "Date Range:")
                    .font(.headline)
                Text(Date()...Date().addingTimeInterval(86400 * 7))
                    .font(.body)
            }
        }
        .padding()
        .navigationTitle("Text Initializers")
    }
}

private struct LayoutExamplesScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(verbatim: "Layout Examples")
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: "VStack .leading alignment:")
                    .font(.headline)
                Text(verbatim: "First line")
                    .font(.body)
                Text(verbatim: "Second line")
                    .font(.body)
            }
            .padding()
            
            HStack(alignment: .top, spacing: 16) {
                VStack {
                    Text(verbatim: "Top")
                        .font(.caption)
                    Text(verbatim: "Aligned")
                        .font(.body)
                }
                
                VStack {
                    Text(verbatim: "HStack")
                        .font(.caption)
                    Text(verbatim: "Example")
                        .font(.body)
                    Text(verbatim: "(3 lines)")
                        .font(.caption)
                }
            }
            .padding()
        }
        .padding()
        .navigationTitle("Layouts")
    }
}

@available(iOS 15, macOS 12, *)
private struct MarkdownExample: View {
    var body: some View {
        VStack {
            Text(verbatim: "Markdown example:")
                .font(.caption)
            Text(markdown: "**Bold**, *italic*, and [links](https://example.com)")
                .font(.body)
        }
    }
}

@available(iOS 14, macOS 11, *)
private struct TimerExample: View {
    var body: some View {
        VStack {
            Text(verbatim: "Countdown timer:")
                .font(.caption)
            Text(timerInterval: Date()...Date().addingTimeInterval(3600))
                .font(.body)
        }
    }
}

enum HomeScreenHandler {
    static func response() -> Data {
        let body = (try? ServerUIJSON.encode(HomeScreen())) ?? Data(#"{ "error":"encode failed" }"#.utf8)
        return HTTP.buildResponse(status: "200 OK", contentType: "application/json", body: body)
    }
}
