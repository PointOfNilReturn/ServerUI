import Foundation

public enum ViewType: Codable, Sendable, Equatable {
    case unknown
    case text(TextSpec)
    case vstack(VStackSpec)
    case hstack(HStackSpec)
}
