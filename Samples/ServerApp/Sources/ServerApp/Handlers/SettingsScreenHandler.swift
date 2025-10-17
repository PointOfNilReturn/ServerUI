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
            Text("⚙️")
                .font(.largeTitle)
                .padding()
            
            Text("Settings Screen")
                .font(.largeTitle)
            
            Text("This screen was fetched from a RELATIVE path")
                .font(.body)
                .padding()
            
            Text("Path: /screen/home/settings")
                .font(.caption)
            
            VStack {
                Text("🔔 Notifications: On")
                Text("🌙 Dark Mode: Auto")
                Text("📍 Location: Enabled")
            }
            .padding()
        }
        .padding()
        .navigationTitle("Settings")
    }
}

