import SwiftUI
import ViewSchema

public struct ViewRenderer {
    public init() {}

    @ViewBuilder
    public func render(_ viewHierarchy: ViewHierarchy) -> some View {
        let type = viewHierarchy.root.type
        switch type {
        case .text(let spec):
            Text(spec)
        default:
            EmptyView()
        }
    }
}
