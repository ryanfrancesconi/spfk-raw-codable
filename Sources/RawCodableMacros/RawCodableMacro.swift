// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

/// Implementation of the `@RawCodable` macro.
///
/// Generates an extension conforming to `Codable` for `RawRepresentable` enums
/// with `String` or `Int` raw values.
public struct RawCodableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Only applies to enums
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MacroError("@RawCodable can only be applied to enums")
        }

        // Find the raw value type from the inheritance clause
        guard let rawType = findRawValueType(in: enumDecl) else {
            throw MacroError("@RawCodable requires a String or Int raw value type")
        }

        // Determine access level from the enum declaration
        let access = accessModifier(for: enumDecl)
        let accessPrefix = access.isEmpty ? "" : "\(access) "

        let extensionDecl: DeclSyntax = """
            extension \(type.trimmed): Codable {
                \(raw: accessPrefix)init(from decoder: any Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let rawValue = try container.decode(\(raw: rawType).self)
                    guard let value = Self(rawValue: rawValue) else {
                        throw DecodingError.dataCorruptedError(
                            in: container,
                            debugDescription: "Unknown \\(Self.self) raw value: \\(rawValue)"
                        )
                    }
                    self = value
                }

                \(raw: accessPrefix)func encode(to encoder: any Encoder) throws {
                    var container = encoder.singleValueContainer()
                    try container.encode(rawValue)
                }
            }
            """

        guard let extensionSyntax = extensionDecl.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionSyntax]
    }

    // MARK: - Helpers

    /// Extracts the raw value type (`String` or `Int`) from the enum's inheritance clause.
    private static func findRawValueType(in enumDecl: EnumDeclSyntax) -> String? {
        guard let inheritanceClause = enumDecl.inheritanceClause else { return nil }

        let supportedRawTypes: Set<String> = ["String", "Int"]

        for inherited in inheritanceClause.inheritedTypes {
            let typeName = inherited.type.trimmedDescription
            if supportedRawTypes.contains(typeName) {
                return typeName
            }
        }

        return nil
    }

    /// Returns the access modifier keyword (e.g. "public") from the enum declaration,
    /// or an empty string if none is present.
    private static func accessModifier(for enumDecl: EnumDeclSyntax) -> String {
        for modifier in enumDecl.modifiers {
            switch modifier.name.tokenKind {
            case .keyword(.public):
                return "public"
            case .keyword(.package):
                return "package"
            case .keyword(.internal):
                return "internal"
            default:
                continue
            }
        }
        return ""
    }
}

// MARK: - Error

struct MacroError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}
