import Foundation
import ServerUI

/// Simple settings demo for relative path navigation.
private struct SettingsDemoScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Settings Demo")
                    .font(.largeTitle)
                
                Text("This view was reached via a relative path!")
                    .font(.caption)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Path: /demo/settings")
                        .font(.caption)
                    Text("Relative from: /demo/navigation")
                        .font(.caption)
                    Text("Relative path: ../settings")
                        .font(.caption)
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}

enum SettingsDemoHandler {
    static func response() -> Data {
        let view = SettingsDemoScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

