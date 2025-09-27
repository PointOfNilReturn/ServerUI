import Foundation

enum Engine {
    static func node<Content: View>(from view: Content) -> Node {
        switch view {
        case let text as Text:
            var node = Node(type: "text")
            node.props["text"] = .string(text.string)
            return node
        default:
            return node(from: view.body)
        }
    }
}

public enum ServerUIJSON {
    public static func encode<Content: View>(_ root: Content, schemaVersion: Int = 1) throws -> Data {
        let node = Engine.node(from: root)
        let envelope = ScreenEnvelope(schemaVersion: schemaVersion, screen: node)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(envelope)
    }
}
