public struct VStackSpec: Codable, Equatable, Sendable {
    public let alignment: HorizontalAlignmentSpec?
    public let spacing: Double?
    public init(alignment: HorizontalAlignmentSpec? = nil, spacing: Double? = nil) {
        self.alignment = alignment; self.spacing = spacing
    }
}
