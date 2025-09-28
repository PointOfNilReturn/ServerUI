import Foundation

public struct Element: Codable {
    public var type: String
    public var properties: [String: Property]
    public var modifiers: [Modifier]
    public var children: [Element]

    public init(
        type: String,
        properties: [String : Property] = [:],
        modifiers: [Modifier] = [],
        children: [Element] = []
    ) {
        self.type = type
        self.properties = properties
        self.modifiers = modifiers
        self.children = children
    }
}
