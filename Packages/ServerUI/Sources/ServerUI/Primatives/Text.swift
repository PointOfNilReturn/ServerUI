import ViewSchema

public struct Text: View {
    public let initializer: TextInitializer

    public init(_ string: String) {
        initializer = .string(string)
    }
    public var body: EmptyView { EmptyView() }
}
