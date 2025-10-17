import Foundation
import ServerUI
import Logging

@main
struct ServerApp {
    static func main() {
        let logger = Logger(label: "com.serverui.app")
        
        do {
            try ServerBootstrap.start(port: 8080)
            RunLoop.main.run()
        } catch {
            logger.critical("Failed to start server", metadata: ["error": "\(error.localizedDescription)"])
            exit(1)
        }
    }
}
