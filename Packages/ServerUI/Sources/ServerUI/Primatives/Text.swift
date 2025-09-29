import ViewSchema

public struct Text: View {
    public let spec: TextSpec

    public init(_ string: String) {
        spec = .string(string)
    }
    public var body: EmptyView { EmptyView() }
}
