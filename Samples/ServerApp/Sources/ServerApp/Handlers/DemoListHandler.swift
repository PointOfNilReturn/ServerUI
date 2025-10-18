import Foundation
import ServerUI

/// Main demo list showing all available component demos.
private struct DemoListScreen: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Text & Typography", absolutePath: "/demo/text")
                NavigationLink("Buttons & Actions", absolutePath: "/demo/buttons")
                NavigationLink("State Management", absolutePath: "/demo/state")
                NavigationLink("Binding & TextFields", absolutePath: "/demo/binding")
                NavigationLink("Layout (VStack, HStack)", absolutePath: "/demo/layout")
                NavigationLink("Navigation", absolutePath: "/demo/navigation")
            }
            .navigationTitle("ServerUI Demos")
        }
    }
}

enum DemoListHandler {
    static func response() -> Data {
        let view = DemoListScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

