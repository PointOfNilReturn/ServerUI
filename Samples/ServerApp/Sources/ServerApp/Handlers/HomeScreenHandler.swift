import Foundation
import ServerUI

private struct HomeScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            // Localized text - will look up in .strings files on client
            Text("greeting.welcome")
                .font(.largeTitle)
            
            // Verbatim text - rendered as-is, no localization
            Text(verbatim: "ServerUI Text Initializer Demo")
                .font(.headline)
            
            // Date formatting examples
            Text(verbatim: "Current time:")
                .font(.caption)
            Text(Date(), style: .time)
                .font(.body)
            
            Text(verbatim: "Relative time:")
                .font(.caption)
            Text(Date().addingTimeInterval(-3600), style: .relative)
                .font(.body)
            
            // Date range
            Text(verbatim: "Date range (7 days):")
                .font(.caption)
            Text(Date()...Date().addingTimeInterval(86400 * 7))
                .font(.body)
            
            // Footer
            Text(verbatim: "©2024 ServerUI Project")
                .font(.caption)
        }
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
