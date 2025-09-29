import Foundation

public struct ViewHierarchy: Codable {
    public let root: ViewNode

    public init(root: ViewNode) {
        self.root = root
    }
}
