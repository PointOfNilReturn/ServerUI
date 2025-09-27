import Foundation

public struct RemoteRoot: Decodable {
    public let schemaVersion: Int
    public let root: Node

    public struct Node: Decodable {
        public let type: String
        public let properties: [String: Property]
        public let modifiers: [Modifier]
        public let children: [Node]
    }

    public struct Modifier: Decodable {
        public let type: String
        public let payload: Property?
    }
}

public enum Property: Decodable {
    case string(String), number(Double)
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) { self = .string(string); return }
        if let number = try? container.decode(Double.self) { self = .number(number); return }
        throw DecodingError.typeMismatch(Property.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSONValue"))
    }

    public var stringValue: String? { if case .string(let string) = self { string } else { nil } }
    public var numberValue: Double? { if case .number(let number) = self { number } else { nil } }
}
