import Foundation
import ServerUI

enum DetailsScreenHandler {
    static func response(path: String) -> Data {
        let body = (try? ServerUIJSON.encode(DetailsScreen(path: path))) ?? Data(#"{ "error":"encode failed" }"#.utf8)
        return HTTP.buildResponse(status: "200 OK", contentType: "application/json", body: body)
    }
}

private struct DetailsScreen: View {
    let path: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📄")
                .font(.largeTitle)
                .padding()
            
            Text("Details Screen")
                .font(.largeTitle)
            
            Text("Type-safe NavigationPath example")
                .font(.body)
                .padding()
            
            VStack(spacing: 8) {
                Text(verbatim: "Requested path:")
                    .font(.caption)
                Text(verbatim: path)
                    .font(.footnote)
                    .padding()
            }
            
            Text(verbatim: "This demonstrates the .relative() path builder")
                .font(.caption)
                .padding(.top, 20)
        }
        .padding()
        .navigationTitle("Details")
    }
}

