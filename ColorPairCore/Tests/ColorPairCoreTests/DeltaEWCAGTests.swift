//
//  DeltaEWCAGTests.swift
//  ColorPairCore
//
//  Created by Maury Alamin on 9/30/25.
//

import Testing
import Foundation
@testable import ColorPairCore

struct DeltaEWCAGTests {
    private let eps = 1e-9

    @Test
    func deltaE_zeroForIdentical() {
        let a = RGBA(r: 0.30, g: 0.50, b: 0.70, a: 1)
        let da = DeltaE.ciede2000(a.toLab(), a.toLab())
        #expect(abs(da - 0.0) < eps)
    }

    @Test
    func deltaE_isSymmetric() {
        let a = RGBA(r: 0.10, g: 0.20, b: 0.30, a: 1)
        let b = RGBA(r: 0.40, g: 0.50, b: 0.60, a: 1)
        let d1 = DeltaE.ciede2000(a.toLab(), b.toLab())
        let d2 = DeltaE.ciede2000(b.toLab(), a.toLab())
        #expect(abs(d1 - d2) < eps)
    }

    @Test
    func wcag_blackWhite_isMaximal() {
        let ratio = WCAG.contrastRatio(fg: RGBA.black, bg: RGBA.white)
        #expect(ratio > 20.9) // ~21.0
        #expect(WCAG.passesAA(normalText: ratio))
    }

    @Test
    func wcag_whiteOnWhite_fails() {
        let ratio = WCAG.contrastRatio(fg: RGBA.white, bg: RGBA.white)
        #expect(ratio == 1.0)
        #expect(!WCAG.passesAA(normalText: ratio))
    }
}
