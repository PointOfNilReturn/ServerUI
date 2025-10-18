import Foundation
import ServerUI

/// Demo showcasing @Binding and TextField.
private struct BindingDemoScreen: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Binding & TextField Demo")
                    .font(.largeTitle)
                
                Text("Text fields with optimistic updates")
                    .font(.caption)
                
                VStack(spacing: 15) {
                    TextField("Enter your name", text: $name)
                    
                    HStack {
                        Text("Name: ")
                        Text(binding: $name)
                    }
                    .font(.caption)
                }
                
                VStack(spacing: 15) {
                    TextField("Enter your email", text: $email)
                    
                    HStack {
                        Text("Email: ")
                        Text(binding: $email)
                    }
                    .font(.caption)
                }
                
                VStack(spacing: 15) {
                    TextField("Enter a message", text: $message)
                    
                    HStack {
                        Text("Message: ")
                        Text(binding: $message)
                    }
                    .font(.caption)
                }
                
                Text("---").padding()
                
                Text("How it works:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Type in TextField → Updates instantly locally")
                        .font(.caption)
                    Text("2. After 300ms → Sends to server (debounced)")
                        .font(.caption)
                    Text("3. Text(binding:) → Shows optimistic cached value")
                        .font(.caption)
                    Text("4. Server confirms → State synced")
                        .font(.caption)
                }
                
                Button("Clear All") {
                    name = ""
                    email = ""
                    message = ""
                }
            }
            .padding()
        }
        .navigationTitle("Binding Demo")
    }
}

enum BindingDemoHandler {
    static func response() -> Data {
        let view = BindingDemoScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

