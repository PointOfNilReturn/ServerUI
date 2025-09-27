import Foundation
import ServerUI

@main
struct ServerApp {
    static func main() {
        do {
            try ServerBootstrap.start(port: 8080)
            RunLoop.main.run()
        } catch {
            print(error)
        }
    }
}
