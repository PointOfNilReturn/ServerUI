import SwiftUI

public struct RemoteRenderer {
    public init() {}

    @ViewBuilder
    public func render(_ hierarchy: ViewHierarchy) -> some View {
        switch hierarchy.root.type {
        case "text":
            Text(hierarchy.root.properties["text"]?.stringValue ?? "")
            
        default:
            EmptyView()
        }
    }
}
