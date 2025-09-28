import SwiftUI
import ViewSchema

public struct ViewRenderer {
    public init() {}

    @ViewBuilder
    public func render(_ hierarchy: Hierarchy) -> some View {
        switch hierarchy.root.type {
        case "text":
            Text(hierarchy.root.properties["text"]?.stringValue ?? "")
        default:
            EmptyView()
        }
    }
}
