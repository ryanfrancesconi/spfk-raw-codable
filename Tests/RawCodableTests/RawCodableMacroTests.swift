// Copyright Ryan Francesconi. All Rights Reserved.

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@testable import RawCodableMacros

@Suite
final class RawCodableMacroTests {
    let macros: [String: Macro.Type] = [
        "RawCodable": RawCodableMacro.self,
    ]

    // MARK: - String raw value

    @Test func expandsForPublicStringEnum() {
        assertMacroExpansion(
            """
            @RawCodable
            public enum Color: String {
                case red
                case green
                case blue
            }
            """,
            expandedSource: """
            public enum Color: String {
                case red
                case green
                case blue
            }

            extension Color: Codable {
                public init(from decoder: any Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let rawValue = try container.decode(String.self)
                    guard let value = Self(rawValue: rawValue) else {
                        throw DecodingError.dataCorruptedError(
                            in: container,
                            debugDescription: "Unknown \\(Self.self) raw value: \\(rawValue)"
                        )
                    }
                    self = value
                }

                public func encode(to encoder: any Encoder) throws {
                    var container = encoder.singleValueContainer()
                    try container.encode(rawValue)
                }
            }
            """,
            macros: macros
        )
    }

    // MARK: - Int raw value

    @Test func expandsForPublicIntEnum() {
        assertMacroExpansion(
            """
            @RawCodable
            public enum Priority: Int {
                case low = 0
                case medium = 1
                case high = 2
            }
            """,
            expandedSource: """
            public enum Priority: Int {
                case low = 0
                case medium = 1
                case high = 2
            }

            extension Priority: Codable {
                public init(from decoder: any Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let rawValue = try container.decode(Int.self)
                    guard let value = Self(rawValue: rawValue) else {
                        throw DecodingError.dataCorruptedError(
                            in: container,
                            debugDescription: "Unknown \\(Self.self) raw value: \\(rawValue)"
                        )
                    }
                    self = value
                }

                public func encode(to encoder: any Encoder) throws {
                    var container = encoder.singleValueContainer()
                    try container.encode(rawValue)
                }
            }
            """,
            macros: macros
        )
    }

    // MARK: - Internal access (no modifier)

    @Test func expandsForInternalEnum() {
        assertMacroExpansion(
            """
            @RawCodable
            enum Status: String {
                case active
                case inactive
            }
            """,
            expandedSource: """
            enum Status: String {
                case active
                case inactive
            }

            extension Status: Codable {
                init(from decoder: any Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let rawValue = try container.decode(String.self)
                    guard let value = Self(rawValue: rawValue) else {
                        throw DecodingError.dataCorruptedError(
                            in: container,
                            debugDescription: "Unknown \\(Self.self) raw value: \\(rawValue)"
                        )
                    }
                    self = value
                }

                func encode(to encoder: any Encoder) throws {
                    var container = encoder.singleValueContainer()
                    try container.encode(rawValue)
                }
            }
            """,
            macros: macros
        )
    }

    // MARK: - Multiple inheritance types

    @Test func expandsWithAdditionalProtocols() {
        assertMacroExpansion(
            """
            @RawCodable
            public enum Mode: String, Sendable, CaseIterable {
                case auto
                case manual
            }
            """,
            expandedSource: """
            public enum Mode: String, Sendable, CaseIterable {
                case auto
                case manual
            }

            extension Mode: Codable {
                public init(from decoder: any Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let rawValue = try container.decode(String.self)
                    guard let value = Self(rawValue: rawValue) else {
                        throw DecodingError.dataCorruptedError(
                            in: container,
                            debugDescription: "Unknown \\(Self.self) raw value: \\(rawValue)"
                        )
                    }
                    self = value
                }

                public func encode(to encoder: any Encoder) throws {
                    var container = encoder.singleValueContainer()
                    try container.encode(rawValue)
                }
            }
            """,
            macros: macros
        )
    }

    // MARK: - Error cases

    @Test func failsOnStruct() {
        assertMacroExpansion(
            """
            @RawCodable
            struct Foo: Codable {
                let x: Int
            }
            """,
            expandedSource: """
            struct Foo: Codable {
                let x: Int
            }
            """,
            diagnostics: [
                .init(message: "@RawCodable can only be applied to enums", line: 1, column: 1),
            ],
            macros: macros
        )
    }

    @Test func failsOnEnumWithoutRawValue() {
        assertMacroExpansion(
            """
            @RawCodable
            enum Direction {
                case north
                case south
            }
            """,
            expandedSource: """
            enum Direction {
                case north
                case south
            }
            """,
            diagnostics: [
                .init(message: "@RawCodable requires a String or Int raw value type", line: 1, column: 1),
            ],
            macros: macros
        )
    }
}
