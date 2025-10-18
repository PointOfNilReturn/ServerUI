import Foundation
import ServerUI

/// Demo showcasing Button with server-side actions.
private struct ButtonsDemoScreen: View {
    @State private var tapCount: Int = 0
    @State private var lastAction: String = "None"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Buttons & Actions Demo")
                    .font(.largeTitle)
                
                Text("Tap Count: \(tapCount)")
                    .font(.title)
                
                Text("Last Action: \(lastAction)")
                    .font(.caption)
                
                VStack(spacing: 15) {
                    Button("Simple Button") {
                        tapCount += 1
                        lastAction = "Simple Button"
                    }
                    
                    Button("Another Button") {
                        tapCount += 1
                        lastAction = "Another Button"
                    }
                    
                    Button("Reset Counter") {
                        tapCount = 0
                        lastAction = "Reset"
                    }
                }
                
                Text("---").padding()
                
                Text("Button with Custom Label")
                    .font(.headline)
                
                Button {
                    tapCount += 1
                    lastAction = "Custom Label Button"
                } label: {
                    HStack {
                        Text("Tap Me")
                        Text("→")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Buttons Demo")
    }
}

enum ButtonsDemoHandler {
    static func response() -> Data {
        let view = ButtonsDemoScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

