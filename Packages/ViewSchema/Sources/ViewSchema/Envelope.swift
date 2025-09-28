import Foundation

public struct Envelope: Codable {
    public let schemaVersion: Int
    public let hierarchy: Hierarchy

    public init(schemaVersion: Int, hierarchy: Hierarchy) {
        self.schemaVersion = schemaVersion
        self.hierarchy = hierarchy
    }
}
