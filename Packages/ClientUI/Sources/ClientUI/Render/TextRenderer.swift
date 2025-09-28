import SwiftUI
import ViewSchema

public extension Text {
    init(_ initializer: TextInitializer) {
        switch initializer {
        case .string(let string): self.init(string)
        }
    }
}
