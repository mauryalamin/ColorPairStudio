//
//  ApproximatedOutputCodingTests.swift
//  ColorPairCore
//
//  Created by Maury Alamin on 9/30/25.
//

import Testing
import Foundation
@testable import ColorPairCore

struct ApproximatedOutputCodingTests {
    @Test
    func decodes_legacyBaseName_toToken() throws {
        // Legacy payload used "baseName": ".indigo"
        let legacy = """
        {"target":{"r":0.3,"g":0.5,"b":0.7,"a":1.0},
         "baseName":".indigo",
         "hueDegrees":0,"saturation":1,"brightness":0,"deltaE":0.0,"wcagPass":true}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(ApproximatedOutput.self, from: legacy)
        #expect(decoded.base == .indigo)
        #expect(decoded.swiftBaseExpr == "Color.indigo")
    }

    @Test
    func encodes_and_decodes_roundTrip() throws {
        let out = ApproximatedOutput(
            target: RGBA(r: 0.3, g: 0.5, b: 0.7, a: 1),
            base: .teal,
            hueDegrees: 12,
            saturation: 0.92,
            brightness: -0.03,
            deltaE: 1.23,
            wcagPass: true
        )
        let data = try JSONEncoder().encode(out)
        let back = try JSONDecoder().decode(ApproximatedOutput.self, from: data)
        #expect(back.base == .teal)
        #expect(back.hueDegrees == 12)
        #expect(abs(back.saturation - 0.92) < 1e-9)
        #expect(abs(back.brightness + 0.03) < 1e-9) // -0.03
    }
}
