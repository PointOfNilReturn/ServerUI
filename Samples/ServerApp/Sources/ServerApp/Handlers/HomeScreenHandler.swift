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
                
                Text("ServerUI Navigation Demo")
                    .font(.headline)
                
                // Embedded Navigation (SwiftUI-mirroring)
                Text("Embedded Navigation")
                    .font(.headline)
                    .padding(.top)
                
                VStack {
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
                Text("Path-Based Navigation")
                    .font(.headline)
                    .padding(.top)
                
                VStack {
                    NavigationLink("Profile (Absolute Path)", absolutePath: "/screen/profile")
                    NavigationLink("Settings (Relative Path)", relativePath: "settings")
                    NavigationLink("User Details (With Query)", absolutePath: "/user", query: ["id": "123"])
                    NavigationLink("Details (Type-Safe)", path: .relative("details"))
                }
                .padding()
                
                // Footer
                Text("©\(Calendar.current.component(.year, from: Date())) ServerUI Project")
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
            Text("Modifier Examples")
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("Padding:")
                    .font(.headline)
                
                Text("Default padding")
                    .font(.body)
                    .padding()
                
                Text("Custom 20pt padding")
                    .font(.body)
                    .padding(20)
            }
            
            VStack(alignment: .leading) {
                Text("Frame:")
                    .font(.headline)
                
                Text("Fixed 200x50")
                    .font(.body)
                    .frame(width: 200, height: 50)
                    .padding(8)
                
                Text("Min width 150")
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
            Text("Text Initializer Examples")
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("Localized:")
                    .font(.headline)
                Text("greeting.welcome")
                    .font(.body)
            }
            
            VStack(alignment: .leading) {
                Text("Verbatim:")
                    .font(.headline)
                Text(verbatim: "©2024 ServerUI")
                    .font(.body)
            }
            
            VStack(alignment: .leading) {
                Text("Date Formatting:")
                    .font(.headline)
                Text(Date(), style: .time)
                    .font(.body)
            }
            
            VStack(alignment: .leading) {
                Text("Date Range:")
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
            Text("Layout Examples")
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("VStack .leading alignment:")
                    .font(.headline)
                Text("First line")
                    .font(.body)
                Text("Second line")
                    .font(.body)
            }
            .padding()
            
            HStack(alignment: .top, spacing: 16) {
                VStack {
                    Text("Top")
                        .font(.caption)
                    Text("Aligned")
                        .font(.body)
                }
                
                VStack {
                    Text("HStack")
                        .font(.caption)
                    Text("Example")
                        .font(.body)
                    Text("(3 lines)")
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
            Text("Markdown example:")
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
            Text("Countdown timer:")
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
