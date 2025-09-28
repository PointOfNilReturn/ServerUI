import SwiftUI
import ViewSchema

public struct ViewRenderer {
    public init() {}

    @ViewBuilder
    public func render(_ hierarchy: Hierarchy) -> some View {
        let type = hierarchy.root.type
        switch type {
        case .text(let initializer):
            Text(initializer)
        default:
            EmptyView()
        }
    }
}
