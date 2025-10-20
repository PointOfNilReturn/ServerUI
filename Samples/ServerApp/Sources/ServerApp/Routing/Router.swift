import Foundation
import ServerUI

enum Router {
    static func respond(method: String, path: String, body: Data? = nil, headers: [String: String] = [:]) -> Data {
        // Extract and activate session from headers (for all requests)
        if let sessionId = headers["X-Session-ID"] {
            SessionManager.shared.activateSession(sessionId)
            SessionManager.shared.activateActionRegistry(sessionId)
        }
        
        // Set the current path for state scoping
        // Include view instance ID if provided to ensure each navigation instance has unique state
        if let viewInstanceId = headers["X-View-Instance-ID"] {
            StateStore.currentPath = "\(path)#\(viewInstanceId)"
        } else {
            StateStore.currentPath = path
        }
        
        // Handle action execution (POST /action)
        if method == "POST" && path == "/action" {
            return ActionHandler.response(body: body, headers: headers)
        }
        
        // Handle state updates (POST /state)
        if method == "POST" && path == "/state" {
            return StateUpdateHandler.response(body: body, headers: headers)
        }
        
        // Handle navigation pop (POST /navigation/pop)
        if method == "POST" && path == "/navigation/pop" {
            return NavigationPopHandler.response(body: body, headers: headers)
        }
        
        // All other routes require GET
        guard method == "GET" else {
            let body = Data(#"{ "error": "method not allowed" }"#.utf8)
            return HTTP.buildResponse(status: "405 Method Not Allowed", body: body)
        }
        
        // Route handling
        switch path {
        // Main demo list
        case "/", "/demo", "/demo/list":
            return DemoListHandler.response()
        
        // Individual demos
        case "/demo/text":
            return TextDemoHandler.response()
        case "/demo/buttons":
            return ButtonsDemoHandler.response()
        case "/demo/state":
            return StateDemoHandler.response()
        case "/demo/binding":
            return BindingDemoHandler.response()
        case "/demo/layout":
            return LayoutDemoHandler.response()
        case "/demo/navigation":
            return NavigationDemoHandler.response()
        case "/demo/observable":
            return ObservableDemoHandler.response()
        case "/demo/settings":
            return SettingsDemoHandler.response()
            
        // Legacy routes (for path-based navigation examples)
        case "/screen/home":
            return DemoListHandler.response()
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
