import ClientUI
import SwiftUI

@main
struct iOSClientApp: App {
    var body: some Scene {
        WindowGroup {
            RemoteView(.local())
        }
    }
}
