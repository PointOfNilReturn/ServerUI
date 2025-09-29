import Foundation

public struct ViewNode: Codable {
    public var type: ViewType
    public var properties: [String: Property]
    public var modifiers: [Modifier]
    public var children: [ViewNode]

    public init(
        type: ViewType,
        properties: [String : Property] = [:],
        modifiers: [Modifier] = [],
        children: [ViewNode] = []
    ) {
        self.type = type
        self.properties = properties
        self.modifiers = modifiers
        self.children = children
    }
}
