# RawCodable

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-raw-codable%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-raw-codable)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-raw-codable%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-raw-codable)

A Swift macro that generates explicit `Codable` conformance for `RawRepresentable` enums.

## Motivation

Swift's synthesized `Codable` for enums can fail under SwiftData's runtime decoder, which uses Key-Value Coding (KVC) to walk the property graph of composite attributes. When SwiftData encounters an enum stored in a composite struct, it needs the enum to handle its own serialization explicitly rather than relying on compiler-synthesized `Codable`. Without this, you get `NSUnknownKeyException` crashes at runtime.

`@RawCodable` eliminates the boilerplate of writing identical `init(from:)` / `encode(to:)` implementations on every `RawRepresentable` enum in your data model.

## Usage

```swift
import RawCodable

@RawCodable
public enum BitDepthRule: String, Sendable {
    case lessThanOrEqual
    case any
}
```

The macro expands to:

```swift
extension BitDepthRule: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let value = Self(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown \(Self.self) raw value: \(rawValue)"
            )
        }
        self = value
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
```

Works with both `String` and `Int` raw values:

```swift
@RawCodable
public enum Priority: Int, Sendable {
    case low = 0
    case medium = 1
    case high = 2
}
```

## Requirements

- Swift 6.2+
- macOS 13+

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ryanfrancesconi/spfk-raw-codable", from: "1.0.0"),
]
```

Then add `RawCodable` to your target's dependencies:

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "RawCodable", package: "spfk-raw-codable"),
    ]
)
```

## License

Copyright Ryan Francesconi. All Rights Reserved.
