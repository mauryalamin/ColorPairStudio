//
//  DerivedPairEnginePolicyTests.swift
//  ColorPairCore
//
//  Created by Maury Alamin on 9/30/25.
//

import Testing
import Foundation
@testable import ColorPairCore

struct DerivedPairEnginePolicyTests {
    private func luminance(_ c: RGBA) -> Double {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v/12.92 : pow((v + 0.055)/1.055, 2.4) }
        let R = lin(c.r), G = lin(c.g), B = lin(c.b)
        return 0.2126*R + 0.7152*G + 0.0722*B
    }

    @Test
    func guardrailed_respectsBackgroundContrast_andOrdering() {
        let t = RGBA(r: 0.30, g: 0.50, b: 0.70, a: 1)
        let p = DerivedPairEngine.derive(from: t, policy: .guardrailed)

        let m = DerivedPairEngine.metrics(for: p)
        #expect(m.light.bg >= 3.0)
        #expect(m.dark.bg  >= 3.0)

        // Dark twin should be lighter than light twin
        #expect(luminance(p.dark) > luminance(p.light))
    }

    @Test
    func exactLightIfCompliant_keepsLightWhenItPasses() {
        // A moderately dark color that passes vs white background (>=3:1)
        let target = RGBA(r: 0.30, g: 0.50, b: 0.70, a: 1)
        let p = DerivedPairEngine.derive(from: target, policy: .exactLightIfCompliant)
        // Light should remain exact
        #expect(abs(p.light.r - target.r) < 1e-12)
        #expect(abs(p.light.g - target.g) < 1e-12)
        #expect(abs(p.light.b - target.b) < 1e-12)
    }

    @Test
    func brandLockedLight_keepsLightEvenIfItFails() {
        // Very light color likely to fail vs white background
        let target = RGBA(r: 0.95, g: 0.95, b: 0.95, a: 1)
        let p = DerivedPairEngine.derive(from: target, policy: .brandLockedLight)
        #expect(abs(p.light.r - target.r) < 1e-12)
        #expect(abs(p.light.g - target.g) < 1e-12)
        #expect(abs(p.light.b - target.b) < 1e-12)
    }

    @Test
    func bias_clamps_and_changesSeparation() {
        let t = RGBA(r: 0.35, g: 0.55, b: 0.20, a: 1)
        let neg = DerivedPairEngine.derive(from: t, bias: -1.0, policy: .guardrailed) // clamps to -0.25
        let pos = DerivedPairEngine.derive(from: t, bias:  1.0, policy: .guardrailed) // clamps to +0.25

        // Separation intuition: positive bias => darker Light, lighter Dark
        #expect(luminance(pos.dark) > luminance(neg.dark))
        #expect(luminance(pos.light) < luminance(neg.light))
    }
}
