//
//  DerivedPairEngine.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

// DerivedPairEngine.swift
enum DerivedPairEngine {

    // Approximate system backgrounds (sRGB). Tweak if you prefer other anchors.
    private static let lightBG = RGBA(r: 1.00, g: 1.00, b: 1.00, a: 1)   // ~NSColor.windowBackgroundColor (light)
    private static let darkBG  = RGBA(r: 0.12, g: 0.12, b: 0.12, a: 1)   // ~#1F1F1F (dark surfaces)

    static func derive(from target: RGBA, bias: Double = 0.0) -> DerivedPair {
        // 1) Start with sensible twins (your earlier intent)
        var light = target.adjust(brightness: (-0.08 + bias))  // darker than target
        var dark  = target.adjust(brightness: ( 0.10 + bias))  // lighter than target

        // 2) Ensure contrast vs background (UI element contrast, ≈ WCAG 3:1)
        light = ensureContrastVSBackground(color: light, bg: lightBG, wantLighter: false, minRatio: 3.0)
        dark  = ensureContrastVSBackground(color: dark,  bg: darkBG,  wantLighter: true,  minRatio: 3.0)

        // 3) Preserve intuitive ordering: dark twin should be lighter than light twin
        if luminance(dark) <= luminance(light) {
            dark = nudge(color: dark, direction: .lighter, steps: 6)
        }

        // 4) (Optional) also compute white-on-color WCAG for the previews’ badge
        let white = RGBA(r: 1, g: 1, b: 1, a: 1)
        let bothPassText = WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: light))
                         && WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: dark))

        return DerivedPair(target: target, light: light, dark: dark, wcagPass: bothPassText)
    }

    // MARK: - Helpers

    private static func ensureContrastVSBackground(color: RGBA,
                                                   bg: RGBA,
                                                   wantLighter: Bool,
                                                   minRatio: Double) -> RGBA {
        var c = color
        var tries = 0
        while WCAG.contrastRatio(fg: c, bg: bg) < minRatio && tries < 48 {
            c = c.adjust(brightness: wantLighter ? 0.02 : -0.02)
            tries += 1
        }
        return c
    }

    private enum Direction { case lighter, darker }
    private static func nudge(color: RGBA, direction: Direction, steps: Int) -> RGBA {
        var c = color
        for _ in 0..<steps {
            c = c.adjust(brightness: direction == .lighter ? 0.02 : -0.02)
        }
        return c
    }

    // Simple relative luminance proxy for ordering (same math WCAG uses internally)
    private static func luminance(_ c: RGBA) -> Double {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v/12.92 : pow((v + 0.055)/1.055, 2.4) }
        let R = lin(c.r), G = lin(c.g), B = lin(c.b)
        return 0.2126*R + 0.7152*G + 0.0722*B
    }
}


