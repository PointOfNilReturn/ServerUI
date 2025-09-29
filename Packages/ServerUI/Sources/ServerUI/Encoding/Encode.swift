import Foundation
import ViewSchema

enum Engine {
    static func viewHierarchy<Content: View>(from view: Content) -> ViewHierarchy {
        ViewHierarchy(root: viewNode(from: view))
    }

    static func viewNode<Content: View>(from view: Content) -> ViewNode {
        switch view {
        case let text as Text:
            ViewNode(type: .text(text.spec))
        default:
            viewNode(from: view.body)
        }
    }
}

public enum ServerUIJSON {
    public static func encode<Content: View>(_ root: Content, schemaVersion: Int = 1) throws -> Data {
        let viewHierarchy = Engine.viewHierarchy(from: root)
        let viewHierarchyEnvelope = ViewHierarchyEnvelope(
            schemaVersion: schemaVersion,
            viewHierarchy: viewHierarchy
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(viewHierarchyEnvelope)
    }
}
