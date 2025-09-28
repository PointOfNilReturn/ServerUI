import Foundation

public struct Hierarchy: Codable {
    public let root: Element

    public init(root: Element) {
        self.root = root
    }
}
