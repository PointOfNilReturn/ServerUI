import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// The compiler plugin that provides ServerUI macros.
@main
struct ServerUIMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObservableMacro.self
    ]
}
