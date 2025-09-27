import Foundation

public struct ViewHierarchyEnvelope: Encodable {
    public let schemaVersion: Int
    public let viewHierarchy: ViewHierarchy
}

public struct ViewHierarchy: Encodable {
    public let root: ViewElement
}

public struct ViewElement: Encodable {
    public var type: String
    public var properties: [String: Property] = [:]
    public var modifiers: [Modifier] = []
    public var children: [ViewElement] = []
}

public enum Property: Encodable {
    case string(String), number(Double)
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let string): try string.encode(to: encoder)
        case .number(let number): try number.encode(to: encoder)
        }
    }
}

public struct Modifier: Encodable {
    public var type: String
    public var payload: Property?
}

