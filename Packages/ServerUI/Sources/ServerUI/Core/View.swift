public protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

public struct EmptyView: View {
    public init() {}
    public var body: EmptyView { self }
}
