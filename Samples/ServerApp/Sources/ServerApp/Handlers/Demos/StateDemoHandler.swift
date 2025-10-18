import Foundation
import ServerUI

/// Demo showcasing @State property wrapper.
private struct StateDemoScreen: View {
    @State private var counter: Int = 0
    @State private var isToggled: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("State Management Demo")
                    .font(.largeTitle)
                
                Text("@State persists across re-renders on the server")
                    .font(.caption)
                
                VStack(spacing: 15) {
                    Text("Counter State")
                        .font(.headline)
                    
                    Text("Count: \(counter)")
                        .font(.title)
                    
                    HStack(spacing: 15) {
                        Button("-") {
                            counter -= 1
                        }
                        
                        Button("+") {
                            counter += 1
                        }
                        
                        Button("Reset") {
                            counter = 0
                        }
                    }
                }
                
                Text("---").padding()
                
                VStack(spacing: 15) {
                    Text("Boolean State")
                        .font(.headline)
                    
                    Text("Toggled: \(isToggled ? "Yes" : "No")")
                    
                    Button(isToggled ? "Turn Off" : "Turn On") {
                        isToggled.toggle()
                    }
                }
                
                Text("---").padding()
                
                Text("State is session-scoped")
                    .font(.caption)
                Text("Each client gets their own state")
                    .font(.caption)
            }
            .padding()
        }
        .navigationTitle("State Demo")
    }
}

enum StateDemoHandler {
    static func response() -> Data {
        let view = StateDemoScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

