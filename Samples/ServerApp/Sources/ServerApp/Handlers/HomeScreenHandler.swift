import Foundation
import ServerUI

private struct HomeScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            // Header with padding
            Text("greeting.welcome")
                .font(.largeTitle)
                .padding()
            
            Text(verbatim: "ServerUI Modifiers Demo")
                .font(.headline)
                .padding(.horizontal, 16)
            
            // Padding examples
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: "Padding Examples:")
                    .font(.headline)
                
                Text(verbatim: "Default padding")
                    .font(.body)
                    .padding()
                
                Text(verbatim: "Custom padding (30pt)")
                    .font(.body)
                    .padding(30)
                
                Text(verbatim: "Horizontal padding only")
                    .font(.body)
                    .padding(.horizontal, 40)
                
                Text(verbatim: "Vertical padding only")
                    .font(.body)
                    .padding(.vertical, 20)
            }
            .padding()
            
            // Frame examples
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: "Frame Examples:")
                    .font(.headline)
                
                Text(verbatim: "Fixed 200x50")
                    .font(.body)
                    .frame(width: 200, height: 50)
                    .padding(8)
                
                Text(verbatim: "Width only")
                    .font(.body)
                    .frame(width: 150)
                    .padding(8)
                
                Text(verbatim: "Min width 100")
                    .font(.body)
                    .frame(minWidth: 100)
                    .padding(8)
                
                HStack(spacing: 16) {
                    Text(verbatim: "Box 1")
                        .font(.caption)
                        .frame(width: 80, height: 80)
                        .padding(8)
                    
                    Text(verbatim: "Box 2")
                        .font(.caption)
                        .frame(width: 80, height: 80)
                        .padding(8)
                }
            }
            .padding()
            
            // Combined modifiers
            VStack(spacing: 8) {
                Text(verbatim: "Combined Modifiers:")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                Text(verbatim: "Font + Padding + Frame")
                    .font(.body)
                    .padding(12)
                    .frame(minWidth: 200)
                
                Text(Date(), style: .time)
                    .font(.body)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .frame(minWidth: 150)
            }
            .padding()
            
            // Footer
            Text(verbatim: "©2024 ServerUI Project")
                .font(.caption)
                .padding(.top, 20)
        }
        .padding()
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
