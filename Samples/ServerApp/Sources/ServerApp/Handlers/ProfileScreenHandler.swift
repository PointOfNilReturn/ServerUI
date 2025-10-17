import Foundation
import ServerUI

enum ProfileScreenHandler {
    static func response() -> Data {
        let body = (try? ServerUIJSON.encode(ProfileScreen())) ?? Data(#"{ "error":"encode failed" }"#.utf8)
        return HTTP.buildResponse(status: "200 OK", contentType: "application/json", body: body)
    }
}

private struct ProfileScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("👤")
                .font(.largeTitle)
                .padding()
            
            Text("Profile Screen")
                .font(.largeTitle)
            
            Text("This screen was fetched on-demand from /screen/profile")
                .font(.body)
                .padding()
            
            VStack {
                Text("Name: John Doe")
                Text("Email: john@example.com")
                Text("Member since: 2024")
            }
            .padding()
            
            Text("✨ Path-based navigation working!")
                .font(.caption)
                .padding(.top, 40)
        }
        .padding()
        .navigationTitle("Profile")
    }
}

