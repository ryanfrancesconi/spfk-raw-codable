// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

import RawCodable

// MARK: - Test enums

@RawCodable
enum StringBacked: String, Sendable {
    case alpha
    case beta
    case gamma
}

@RawCodable
public enum IntBacked: Int, Sendable {
    case low = 0
    case medium = 1
    case high = 2
}

// MARK: - Tests

@Suite
final class RawCodableRuntimeTests {
    @Test func stringEnumRoundTrips() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let original = StringBacked.beta
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(StringBacked.self, from: data)

        #expect(decoded == original)

        // Verify it encodes as the raw string value
        let json = String(data: data, encoding: .utf8)
        #expect(json == "\"beta\"")
    }

    @Test func intEnumRoundTrips() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let original = IntBacked.high
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(IntBacked.self, from: data)

        #expect(decoded == original)

        // Verify it encodes as the raw int value
        let json = String(data: data, encoding: .utf8)
        #expect(json == "2")
    }

    @Test func decodingInvalidRawValueThrows() {
        let decoder = JSONDecoder()
        let invalidJSON = "\"nonexistent\"".data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(StringBacked.self, from: invalidJSON)
        }
    }

    @Test func allStringCasesRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for original in [StringBacked.alpha, .beta, .gamma] {
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(StringBacked.self, from: data)
            #expect(decoded == original)
        }
    }

    @Test func allIntCasesRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for original in [IntBacked.low, .medium, .high] {
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(IntBacked.self, from: data)
            #expect(decoded == original)
        }
    }
}
