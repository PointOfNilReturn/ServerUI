import SwiftUI

public struct RemoteRenderer {
    public init() {}

    @ViewBuilder
    public func render(_ node: RemoteRoot.Node) -> some View {
        switch node.type {
        case "text":
            Text(node.properties["text"]?.stringValue ?? "")
            
        default:
            EmptyView()
        }
    }
}
