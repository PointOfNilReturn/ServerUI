public protocol SchemaConvertible {
    func toViewNode() -> ViewNode
}

extension ViewNode: SchemaConvertible {
    public func toViewNode() -> ViewNode { self }
}

@resultBuilder
public struct SchemaBuilder {
    public static func buildBlock() -> [ViewNode] { [] }
    public static func buildBlock(_ comps: SchemaConvertible...) -> [ViewNode] { comps.map { $0.toViewNode() } }
    public static func buildEither(first: [ViewNode]) -> [ViewNode] { first }
    public static func buildEither(second: [ViewNode]) -> [ViewNode] { second }
    public static func buildOptional(_ comp: [ViewNode]?) -> [ViewNode] { comp ?? [] }
    public static func buildArray(_ arrays: [[ViewNode]]) -> [ViewNode] { arrays.flatMap { $0 } }
    public static func buildExpression(_ expr: SchemaConvertible) -> [ViewNode] { [expr.toViewNode()] }
}
