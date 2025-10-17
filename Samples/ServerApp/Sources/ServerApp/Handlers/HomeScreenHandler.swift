import Foundation
import ServerUI

private struct HomeScreen: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // Header
            Text("greeting.welcome")
                .font(.largeTitle)
            
            Text(verbatim: "Stack Layout & Text Initializer Demo")
                .font(.headline)
            
            // VStack alignment examples
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: "VStack with .leading alignment:")
                    .font(.caption)
                Text(verbatim: "First line (left aligned)")
                    .font(.body)
                Text(verbatim: "Second line (also left aligned)")
                    .font(.body)
            }
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(verbatim: "VStack with .trailing alignment:")
                    .font(.caption)
                Text(verbatim: "First line (right aligned)")
                    .font(.body)
                Text(verbatim: "Second line (also right aligned)")
                    .font(.body)
            }
            
            // HStack alignment examples
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .center, spacing: 4) {
                    Text(verbatim: "Top")
                        .font(.caption)
                    Text(verbatim: "Aligned")
                        .font(.body)
                }
                
                VStack(alignment: .center, spacing: 4) {
                    Text(verbatim: "HStack")
                        .font(.caption)
                    Text(verbatim: "Example")
                        .font(.body)
                    Text(verbatim: "(3 lines)")
                        .font(.caption)
                }
                
                VStack(alignment: .center, spacing: 4) {
                    Text(verbatim: "With")
                        .font(.caption)
                    Text(verbatim: "Spacing")
                        .font(.body)
                }
            }
            
            // Date formatting examples
            VStack(alignment: .center, spacing: 8) {
                Text(verbatim: "Date & Time Examples:")
                    .font(.caption)
                
                HStack(spacing: 8) {
                    Text(verbatim: "Time:")
                        .font(.caption)
                    Text(Date(), style: .time)
                        .font(.body)
                }
                
                HStack(spacing: 8) {
                    Text(verbatim: "Relative:")
                        .font(.caption)
                    Text(Date().addingTimeInterval(-3600), style: .relative)
                        .font(.body)
                }
                
                HStack(spacing: 8) {
                    Text(verbatim: "Range:")
                        .font(.caption)
                    Text(Date()...Date().addingTimeInterval(86400 * 7))
                        .font(.body)
                }
            }
            
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
