import Foundation

public struct ViewHierarchyEnvelope: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let viewHierarchy: ViewHierarchy

    public init(schemaVersion: Int, viewHierarchy: ViewHierarchy) {
        self.schemaVersion = schemaVersion
        self.viewHierarchy = viewHierarchy
    }
}
