import Foundation
import ServerUI

enum Router {
    static func respond(method: String, path: String, body: Data? = nil, headers: [String: String] = [:]) -> Data {
        // Extract and activate session from headers (for all requests)
        if let sessionId = headers["X-Session-ID"] {
            SessionManager.shared.activateSession(sessionId)
            SessionManager.shared.activateActionRegistry(sessionId)
        }
        
        // Handle action execution (POST /action)
        if method == "POST" && path == "/action" {
            return ActionHandler.response(body: body, headers: headers)
        }
        
        // Handle state updates (POST /state)
        if method == "POST" && path == "/state" {
            return StateUpdateHandler.response(body: body, headers: headers)
        }
        
        // All other routes require GET
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
