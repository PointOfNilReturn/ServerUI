import Foundation
import ServerUI

/// Main demo list showing all available component demos.
private struct DemoListScreen: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Text & Typography", path: "/demo/text")
                NavigationLink("Buttons & Actions", path: "/demo/buttons")
                NavigationLink("State Management", path: "/demo/state")
                NavigationLink("Binding & TextFields", path: "/demo/binding")
                NavigationLink("Observable Objects", path: "/demo/observable")
                NavigationLink("Layout (VStack, HStack)", path: "/demo/layout")
                NavigationLink("Navigation", path: "/demo/navigation")
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

