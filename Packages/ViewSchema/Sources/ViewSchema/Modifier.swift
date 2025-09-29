import Foundation

public enum Modifier: Codable, Equatable, Sendable {
    case font(FontRole)
}

public enum FontRole: String, Codable, Equatable, Sendable {
    case largeTitle, title, headline, body, footnote, caption
}
