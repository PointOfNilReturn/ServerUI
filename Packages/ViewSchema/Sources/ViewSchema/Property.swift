import Foundation

public enum Property: Codable, Sendable, Equatable {
    case string(String)
    case number(Double)

    public var stringValue: String? { if case .string(let string) = self { string } else { nil } }
    public var numberValue: Double? { if case .number(let number) = self { number } else { nil } }
}
