import Foundation
import ServerUI

/// Demo view showcasing @State, @Binding, Button, and TextField with server-side state management.
private struct HomeScreen: View {
    @State private var count: Int = 0
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                Text("ServerUI State Demo")
                    .font(.largeTitle)
                    .padding()
                
                // TextField Section
                VStack(spacing: 15) {
                    Text("Text Fields & Binding")
                        .font(.headline)
                    
                    TextField("Enter your name", text: $name)
                    TextField("Enter your email", text: $email)
                    
                    HStack {
                        Text("Name: ")
                        Text(binding: $name)
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("Email: ")
                        Text(binding: $email)
                    }
                    .font(.caption)
                }
                .padding()
                
                // Divider
                Text("---").padding()
                
                // Counter Section
                VStack(spacing: 15) {
                    Text("Counter & Buttons")
                        .font(.headline)
                    
                    Text("Count: \(count)")
                        .font(.title)
                        .padding()
                    
                    HStack(spacing: 15) {
                        Button("Decrement") {
                            count -= 1
                        }
                        
                        Button("Increment") {
                            count += 1
                        }
                        
                        Button("Reset") {
                            count = 0
                        }
                    }
                }
                .padding()
                
                // Divider
                Text("---").padding()
                
                // Navigation Examples
                Text("Navigation")
                    .font(.headline)
                
                VStack {
                    NavigationLink("Profile (Path-Based)", absolutePath: "/screen/profile")
                    NavigationLink("Settings", relativePath: "settings")
                }
                .padding()
                
                // Footer
                Text("©\(Calendar.current.component(.year, from: Date())) ServerUI Project")
                    .font(.caption)
                    .padding(.top)
            }
            .navigationTitle("Home")
        }
    }
}

enum HomeScreenHandler {
    static func response() -> Data {
        let view = HomeScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}
