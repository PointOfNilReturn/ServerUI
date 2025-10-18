import Foundation
import ServerUI

/// Demo showcasing VStack and HStack layouts.
private struct LayoutDemoScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Layout Demo")
                    .font(.largeTitle)
                
                VStack(spacing: 10) {
                    Text("VStack (Vertical)")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        Text("Item 1")
                        Text("Item 2")
                        Text("Item 3")
                    }
                }
                
                Text("---").padding()
                
                VStack(spacing: 10) {
                    Text("HStack (Horizontal)")
                        .font(.headline)
                    
                    HStack(spacing: 10) {
                        Text("A")
                        Text("B")
                        Text("C")
                    }
                }
                
                Text("---").padding()
                
                VStack(spacing: 10) {
                    Text("VStack with Custom Spacing")
                        .font(.headline)
                    
                    VStack(spacing: 20) {
                        Text("Wide")
                        Text("Spacing")
                        Text("Here")
                    }
                }
                
                Text("---").padding()
                
                VStack(spacing: 10) {
                    Text("Nested Stacks")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("Row 1, Col 1")
                            Text("Row 1, Col 2")
                        }
                        HStack {
                            Text("Row 2, Col 1")
                            Text("Row 2, Col 2")
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Layout Demo")
    }
}

enum LayoutDemoHandler {
    static func response() -> Data {
        let view = LayoutDemoScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

