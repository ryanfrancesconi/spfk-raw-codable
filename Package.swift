// swift-tools-version: 6.2
// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "spfk-raw-codable",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "RawCodable",
            targets: ["RawCodable"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "603.0.0-prerelease"),
    ],
    targets: [
        .target(
            name: "RawCodable",
            dependencies: ["RawCodableMacros"]
        ),
        .macro(
            name: "RawCodableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "RawCodableTests",
            dependencies: [
                "RawCodable",
                "RawCodableMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
