public enum HorizontalAlignmentSpec: String, Codable, Equatable, Sendable {
    case leading, center, trailing
}

public enum VerticalAlignmentSpec: String, Codable, Equatable, Sendable {
    case top, center, bottom, firstTextBaseline, lastTextBaseline
}
