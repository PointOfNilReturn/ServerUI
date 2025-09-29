import Foundation

public struct ViewHierarchy: Codable, Sendable, Equatable {
    public let root: ViewNode

    public init(root: ViewNode) {
        self.root = root
    }
}
