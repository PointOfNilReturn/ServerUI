import Foundation

public struct Modifier: Codable {
    public let type: String
    public let payload: Property?

    init(type: String, payload: Property?) {
        self.type = type
        self.payload = payload
    }
}
