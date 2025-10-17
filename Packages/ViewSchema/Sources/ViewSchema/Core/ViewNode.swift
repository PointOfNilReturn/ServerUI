import Foundation

public struct ViewNode: Codable, Sendable, Equatable, Hashable {
    public var type: ViewType
    public var modifiers: [Modifier]
    public var children: [ViewNode]

    public init(
        type: ViewType,
        modifiers: [Modifier] = [],
        children: [ViewNode] = []
    ) {
        self.type = type
        self.modifiers = modifiers
        self.children = children
    }
}
