import Foundation

public struct Node: Encodable {
    public var type: String
    public var props: [String: JSONValue] = [:]
    public var modifiers: [ModifierBox] = []
    public var children: [Node] = []
}

public enum JSONValue: Encodable {
    case string(String), number(Double)
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let string): try string.encode(to: encoder)
        case .number(let number): try number.encode(to: encoder)
        }
    }
}

public struct ModifierBox: Encodable {
    public var type: String
    public var payload: JSONValue?
}

public struct ScreenEnvelope: Encodable {
    public let schemaVersion: Int
    public let screen: Node
}
