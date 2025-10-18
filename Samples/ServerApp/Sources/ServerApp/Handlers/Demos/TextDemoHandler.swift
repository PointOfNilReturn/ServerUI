import Foundation
import ServerUI

/// Demo showcasing Text view with various initializers.
private struct TextDemoScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Text & Typography Demo")
                    .font(.largeTitle)
                
                VStack(spacing: 10) {
                    Text("Localized Text")
                        .font(.headline)
                    Text("greeting.welcome")
                        .font(.body)
                }
                
                VStack(spacing: 10) {
                    Text("Verbatim Text")
                        .font(.headline)
                    Text(verbatim: "©\(Calendar.current.component(.year, from: Date())) ServerUI")
                        .font(.caption)
                }
                
                VStack(spacing: 10) {
                    Text("Font Styles")
                        .font(.headline)
                    Text("Large Title").font(.largeTitle)
                    Text("Title").font(.title)
                    Text("Headline").font(.headline)
                    Text("Body").font(.body)
                    Text("Caption").font(.caption)
                    Text("Footnote").font(.footnote)
                }
                
                VStack(spacing: 10) {
                    Text("Date Formatting")
                        .font(.headline)
                    Text(Date(), style: .date)
                    Text(Date(), style: .time)
                    Text(Date(), style: .relative)
                }
            }
            .padding()
        }
        .navigationTitle("Text Demo")
    }
}

enum TextDemoHandler {
    static func response() -> Data {
        let view = TextDemoScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

