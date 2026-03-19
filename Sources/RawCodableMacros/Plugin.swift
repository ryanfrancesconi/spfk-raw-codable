// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct RawCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RawCodableMacro.self,
    ]
}
