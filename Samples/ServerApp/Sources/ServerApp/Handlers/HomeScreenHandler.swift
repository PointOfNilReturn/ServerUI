import Foundation
import ServerUI

private struct HomeScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Hello from ServerUI!")
                .font(.largeTitle)
            
            Text("This view has multiple children")
                .font(.headline)
            
            HStack(spacing: 15) {
                Text("Left")
                    .font(.body)
                Text("Center")
                    .font(.body)
                Text("Right")
                    .font(.body)
            }
            
            Text("Built with parameter packs! 🎉")
                .font(.footnote)
        }
    }
}

enum HomeScreenHandler {
    static func response() -> Data {
        let body = (try? ServerUIJSON.encode(HomeScreen())) ?? Data(#"{ "error":"encode failed" }"#.utf8)
        return HTTP.buildResponse(status: "200 OK", contentType: "application/json", body: body)
    }
}
