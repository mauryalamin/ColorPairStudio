//
//  ColorPairStudioTests.swift
//  ColorPairStudioTests
//
//  Created by Maury Alamin on 8/26/25.
//

import Testing
import Foundation
@testable import ColorPairStudio

struct ColorPairStudioCoreTests {

    // MARK: - Helpers
    private func luminance(_ c: RGBA) -> Double {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v/12.92 : pow((v + 0.055)/1.055, 2.4) }
        let R = lin(c.r), G = lin(c.g), B = lin(c.b)
        return 0.2126*R + 0.7152*G + 0.0722*B
    }

    // MARK: - SystemColorToken

    @Test
    func token_normalization_and_expr() {
        #expect(SystemColorToken(normalizing: ".red") == .red)
        #expect(SystemColorToken(normalizing: "red") == .red)
        #expect(SystemColorToken(normalizing: "Color.red") == .red)
        #expect(SystemColorToken.red.swiftExpr == "Color.red")
    }

    // MARK: - ApproximatedOutput Codable (new + legacy)

    @Test
    func approximatedOutput_codable_roundTrip() throws {
        let out = ApproximatedOutput(
            target: RGBA(r: 0.3, g: 0.5, b: 0.7, a: 1),
            base: .indigo,
            hueDegrees: 0, saturation: 1, brightness: 0,
            deltaE: 0, wcagPass: true
        )
        let data = try JSONEncoder().encode(out)
        let decoded = try JSONDecoder().decode(ApproximatedOutput.self, from: data)
        #expect(decoded.base == .indigo)
        #expect(decoded.swiftBaseExpr == "Color.indigo")
    }

    @Test
    func approximatedOutput_codable_legacyBaseName() throws {
        // Legacy payload that used "baseName": ".indigo"
        let legacy = """
        {"target":{"r":0.3,"g":0.5,"b":0.7,"a":1.0},
         "baseName":".indigo",
         "hueDegrees":0,"saturation":1,"brightness":0,"deltaE":0.0,"wcagPass":true}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(ApproximatedOutput.self, from: legacy)
        #expect(decoded.base == .indigo)
        #expect(decoded.swiftBaseExpr == "Color.indigo")
    }

    // MARK: - Exporter (Approximator)

    @Test
    func exporter_approximatorSnippet_noDoublePrefix_noIdentityMods() {
        let out = ApproximatedOutput(
            target: RGBA(r: 0.3, g: 0.5, b: 0.7, a: 1),
            base: .indigo,
            hueDegrees: 0, saturation: 1, brightness: 0,
            deltaE: 0, wcagPass: true
        )
        let snippet = Exporter.approximatorSnippet(output: out)
        #expect(!snippet.contains("Color.Color."))
        #expect(!snippet.contains("Color.."))
        #expect(snippet.contains("Color.indigo"))
        // Identity modifiers should be trimmed
        #expect(!snippet.contains(".saturation("))
        #expect(!snippet.contains(".brightness("))
        #expect(!snippet.contains(".hueRotation("))
    }

    // MARK: - DerivedPairEngine

    @Test
    func derivedPair_order_darkIsLighterThanLight() {
        let target = RGBA(r: 0.40, g: 0.42, b: 0.80, a: 1)
        let pair = DerivedPairEngine.derive(from: target, bias: 0.0, policy: .guardrailed)
        #expect(luminance(pair.dark) > luminance(pair.light))  // “Dark” twin should be lighter
    }

    @Test
    func derivedPair_exactLightIfCompliant_keepsLightWhenSafe() {
        // A dark-ish brand that should be compliant on Light backgrounds
        let target = RGBA(r: 0.10, g: 0.20, b: 0.30, a: 1)
        let pair = DerivedPairEngine.derive(from: target, bias: 0.0, policy: .exactLightIfCompliant)
        #expect(abs(pair.light.r - target.r) < 1e-9)
        #expect(abs(pair.light.g - target.g) < 1e-9)
        #expect(abs(pair.light.b - target.b) < 1e-9)
    }

    @Test
    func derivedPair_regression_noBlackLight() {
        // Guard against the previous “light swatch becomes #000000” bug
        let target = RGBA(r: 0.60, g: 0.50, b: 0.20, a: 1)
        let pair = DerivedPairEngine.derive(from: target, bias: 0.0, policy: .guardrailed)
        #expect(pair.light.r + pair.light.g + pair.light.b > 0.0)
    }
    
    @Test
    func policy_toggle_maps_correctly() {
      #expect(PairPolicy.fromToggle(true)  == .exactLightIfCompliant)
      #expect(PairPolicy.fromToggle(false) == .guardrailed)
    }
    
    @Test
    func exporter_derivedPairSnippet_smoke() {
      let t = RGBA(r: 0.3, g: 0.5, b: 0.7, a: 1)
      let p = DerivedPairEngine.derive(from: t, bias: 0, policy: .guardrailed)
      let s = Exporter.derivedPairSnippet(name: "BrandPrimary", pair: p)
      #expect(s.contains("extension Color { static let brandPrimary"))
      #expect(s.contains("Color(\"BrandPrimary\")"))
    }
}
