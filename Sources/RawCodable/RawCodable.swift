// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

/// Generates explicit `Codable` conformance for `RawRepresentable` enums.
///
/// Attach `@RawCodable` to an enum with a `String` or `Int` raw value to generate
/// `init(from:)` and `encode(to:)` that decode/encode via the raw value,
/// replacing Swift's synthesized Codable which can fail under SwiftData's
/// runtime decoder.
///
/// ```swift
/// @RawCodable
/// public enum BitDepthRule: String, Sendable {
///     case lessThanOrEqual
///     case any
/// }
/// ```
///
/// Expands to an extension adding `Codable` conformance:
/// ```swift
/// extension BitDepthRule: Codable {
///     public init(from decoder: any Decoder) throws {
///         let container = try decoder.singleValueContainer()
///         let rawValue = try container.decode(String.self)
///         guard let value = Self(rawValue: rawValue) else {
///             throw DecodingError.dataCorruptedError(
///                 in: container,
///                 debugDescription: "Unknown \(Self.self) raw value: \(rawValue)"
///             )
///         }
///         self = value
///     }
///
///     public func encode(to encoder: any Encoder) throws {
///         var container = encoder.singleValueContainer()
///         try container.encode(rawValue)
///     }
/// }
/// ```
@attached(extension, conformances: Codable, names: named(init(from:)), named(encode(to:)))
public macro RawCodable() = #externalMacro(module: "RawCodableMacros", type: "RawCodableMacro")
