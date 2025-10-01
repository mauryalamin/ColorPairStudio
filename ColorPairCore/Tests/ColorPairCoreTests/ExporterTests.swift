//
//  ExporterTests.swift
//  ColorPairCore
//
//  Created by Maury Alamin on 9/30/25.
//

import Testing
import Foundation
@testable import ColorPairCore

struct ExporterTests {
    @Test
    func approximatorSnippet_noDoubleDot_or_DoubleColor() {
        let out = ApproximatedOutput(
            target: RGBA(r: 0.3, g: 0.5, b: 0.7, a: 1),
            base: .indigo,
            hueDegrees: 0,     // identity
            saturation: 1.0,   // identity
            brightness: 0.0,   // identity
            deltaE: 0.0,
            wcagPass: true
        )
        let s = Exporter.approximatorSnippet(output: out)
        #expect(!s.contains("Color.."))
        #expect(!s.contains("Color.Color."))
        #expect(s.contains("fill(Color.indigo)"))
        // Identity modifiers should be omitted
        #expect(!s.contains("hueRotation(.degrees(0))"))
        #expect(!s.contains(".saturation(1"))
        #expect(!s.contains(".brightness(0"))
    }

    @Test
    func derivedPairSnippet_containsAssetUsage() {
        let t = RGBA(r: 0.3, g: 0.5, b: 0.7, a: 1)
        let p = DerivedPairEngine.derive(from: t, policy: .guardrailed)
        let s = Exporter.derivedPairSnippet(name: "Brand Primary", pair: p)
        #expect(s.contains("extension Color { static let brandPrimary"))
        #expect(s.contains("Color(\"Brand Primary\")"))
    }
}
