import Foundation

enum Router {
    static func respond(method: String, path: String) -> Data {
        if method == "GET", path == "/screen/home" {
            return HomeScreenHandler.response()
        } else {
            let body = Data(#"{ "error": "not found" }"#.utf8)
            return HTTP.buildResponse(status: "404 Not Found", body: body)
        }
    }
}
