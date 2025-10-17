import Foundation
import ServerUI

enum SettingsScreenHandler {
    static func response() -> Data {
        let body = (try? ServerUIJSON.encode(SettingsScreen())) ?? Data(#"{ "error":"encode failed" }"#.utf8)
        return HTTP.buildResponse(status: "200 OK", contentType: "application/json", body: body)
    }
}

private struct SettingsScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(verbatim: "⚙️")
                .font(.largeTitle)
                .padding()
            
            Text(verbatim: "Settings Screen")
                .font(.largeTitle)
            
            Text(verbatim: "This screen was fetched from a RELATIVE path")
                .font(.body)
                .padding()
            
            Text(verbatim: "Path: /screen/home/settings")
                .font(.caption)
            
            VStack(spacing: 12) {
                Text(verbatim: "🔔 Notifications: On")
                Text(verbatim: "🌙 Dark Mode: Auto")
                Text(verbatim: "📍 Location: Enabled")
            }
            .padding()
        }
        .padding()
        .navigationTitle("Settings")
    }
}

