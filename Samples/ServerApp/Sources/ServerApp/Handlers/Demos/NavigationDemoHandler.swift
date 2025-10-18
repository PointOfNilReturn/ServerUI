import Foundation
import ServerUI

/// Demo showcasing Navigation features.
private struct NavigationDemoScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Navigation Demo")
                    .font(.largeTitle)
                
                VStack(spacing: 10) {
                    Text("Embedded Navigation")
                        .font(.headline)
                    Text("Destination is sent with the link")
                        .font(.caption)
                    
                    NavigationLink("Go to Detail 1") {
                        DetailView(title: "Detail 1")
                    }
                    
                    NavigationLink("Go to Detail 2") {
                        DetailView(title: "Detail 2")
                    }
                }
                
                Text("---").padding()
                
                VStack(spacing: 10) {
                    Text("Path-Based Navigation")
                        .font(.headline)
                    Text("Destination fetched on demand")
                        .font(.caption)
                    
                    NavigationLink("Profile (Absolute)", absolutePath: "/screen/profile")
                    NavigationLink("Settings (Relative)", relativePath: "../settings")
                }
                
                Text("---").padding()
                
                VStack(spacing: 10) {
                    Text("With Query Parameters")
                        .font(.headline)
                    
                    NavigationLink("User Details", absolutePath: "/user", query: ["id": "123"])
                }
            }
            .padding()
        }
        .navigationTitle("Navigation Demo")
    }
}

/// Simple detail view for embedded navigation.
private struct DetailView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.largeTitle)
            
            Text("This view was embedded in the NavigationLink")
                .font(.caption)
            
            Text("Navigate back using the system back button")
                .font(.caption)
        }
        .padding()
        .navigationTitle(title)
    }
}

enum NavigationDemoHandler {
    static func response() -> Data {
        let view = NavigationDemoScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

