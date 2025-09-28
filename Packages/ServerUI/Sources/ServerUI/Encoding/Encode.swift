import Foundation
import ViewSchema

enum Engine {
    static func hierarchy<Content: View>(from view: Content) -> Hierarchy {
        Hierarchy(root: element(from: view))
    }

    static func element<Content: View>(from view: Content) -> Element {
        switch view {
        case let text as Text:
            var element = Element(type: "text")
            element.properties["text"] = .string(text.string)
            return element
        default:
            return element(from: view.body)
        }
    }
}

public enum ServerUIJSON {
    public static func encode<Content: View>(_ root: Content, schemaVersion: Int = 1) throws -> Data {
        let hierarchy = Engine.hierarchy(from: root)
        let envelope = Envelope(schemaVersion: schemaVersion, hierarchy: hierarchy)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(envelope)
    }
}
