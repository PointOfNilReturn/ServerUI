public struct HStackSpec: Codable, Equatable, Sendable {
    public let alignment: VerticalAlignmentSpec?
    public let spacing: Double?
    public init(alignment: VerticalAlignmentSpec? = nil, spacing: Double? = nil) {
        self.alignment = alignment; self.spacing = spacing
    }
}
