import ClientUI
import SwiftUI

@main
struct iOSClientApp: App {
    var body: some Scene {
        WindowGroup {
            RemoteView(url: URL(string: "http://127.0.0.1:8080/screen/home")!)
        }
    }
}
