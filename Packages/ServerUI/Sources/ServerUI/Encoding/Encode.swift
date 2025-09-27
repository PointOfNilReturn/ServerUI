import Foundation

enum Engine {
    static func viewHierarchy<Content: View>(from view: Content) -> ViewHierarchy {
        ViewHierarchy(root: viewElement(from: view))
    }

    static func viewElement<Content: View>(from view: Content) -> ViewElement {
        switch view {
        case let text as Text:
            var viewElement = ViewElement(type: "text")
            viewElement.properties["text"] = .string(text.string)
            return viewElement
        default:
            return viewElement(from: view.body)
        }
    }
}

public enum ServerUIJSON {
    public static func encode<Content: View>(_ root: Content, schemaVersion: Int = 1) throws -> Data {
        let viewHierarchy = Engine.viewHierarchy(from: root)
        let envelope = ViewHierarchyEnvelope(schemaVersion: schemaVersion, viewHierarchy: viewHierarchy)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(envelope)
    }
}
