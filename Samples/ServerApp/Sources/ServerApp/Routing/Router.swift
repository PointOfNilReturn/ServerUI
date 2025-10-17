import Foundation

enum Router {
    static func respond(method: String, path: String) -> Data {
        guard method == "GET" else {
            let body = Data(#"{ "error": "method not allowed" }"#.utf8)
            return HTTP.buildResponse(status: "405 Method Not Allowed", body: body)
        }
        
        // Route handling
        switch path {
        case "/screen/home":
            return HomeScreenHandler.response()
            
        case "/screen/profile":
            return ProfileScreenHandler.response()
            
        case "/screen/home/settings":
            return SettingsScreenHandler.response()
            
        case let p where p.hasPrefix("/screen/home/details"):
            return DetailsScreenHandler.response(path: p)
            
        case let p where p.hasPrefix("/user"):
            return UserScreenHandler.response(path: p)
            
        default:
            let body = Data(#"{ "error": "not found", "path": "\(path)" }"#.utf8)
            return HTTP.buildResponse(status: "404 Not Found", body: body)
        }
    }
}
