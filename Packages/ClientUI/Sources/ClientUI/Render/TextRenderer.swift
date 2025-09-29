import SwiftUI
import ViewSchema

public extension Text {
    init(_ spec: TextSpec) {
        switch spec {
        case .string(let string): self.init(string)
        }
    }
}
