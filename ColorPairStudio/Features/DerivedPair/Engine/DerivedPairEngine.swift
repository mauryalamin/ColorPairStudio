//
//  DerivedPairEngine.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation
import AppKit

enum DerivedPairEngine {
    // MARK: - System backgrounds

    /// Resolve a system background color for a specific appearance and convert to sRGB RGBA.
    private static func makeSystemBG(_ appearanceName: NSAppearance.Name) -> RGBA {
        var resolved = NSColor.windowBackgroundColor
        if let appearance = NSAppearance(named: appearanceName) {
            appearance.performAsCurrentDrawingAppearance {
                resolved = NSColor.windowBackgroundColor
            }
        }
        let s = resolved.usingColorSpace(NSColorSpace.sRGB) ?? resolved
        return RGBA(
            r: Double(s.redComponent),
            g: Double(s.greenComponent),
            b: Double(s.blueComponent),
            a: 1
        )
    }
    

    // Cache once; adjust to computed vars if you ever need these to update at runtime.
    private static let lightBG: RGBA = makeSystemBG(.aqua)
    private static let darkBG:  RGBA = makeSystemBG(.darkAqua)

    // MARK: - Bias controls

    /// Allowable user bias range (UI slider should match this).
    private static let biasRange: ClosedRange<Double> = -0.25...0.25

    /// How strongly bias influences brightness (tune to taste).
    private static let biasScale: Double = 0.12

    // MARK: - API

    /// Derive Light/Dark twins from a target color.
    /// Positive `bias` => lighter dark twin & darker light twin (more separation).
    // DerivedPairEngine.swift
    static func derive(from target: RGBA,
                       bias: Double = 0.0,
                       policy: PairPolicy = .exactLightIfCompliant) -> DerivedPair {

        let clampedBias = bias.clamped(to: biasRange)
        let biasScale: Double = 1.0

        // Tuned base offsets (feel “Mac-right”)
        let baseLightOffset = -0.08    // darken in Light mode
        let baseDarkOffset  =  0.10    // lighten in Dark mode

        // Helpers
        func ensureUIContrast(_ c: RGBA, bg: RGBA) -> RGBA {
            ensureContrast(color: c, bg: bg, minRatio: 3.0)  // ~UI legibility guardrail
        }

        // Start with defaults; we’ll fill them per policy
        var light = target
        var dark  = target

        switch policy {
        case .guardrailed:
            // Both twins may move (previous behavior)
            light = target.adjust(brightness: baseLightOffset - clampedBias * biasScale)
            dark  = target.adjust(brightness: baseDarkOffset  + clampedBias * biasScale)
            light = ensureUIContrast(light, bg: lightBG)
            dark  = ensureUIContrast(dark,  bg: darkBG)

        case .exactLightIfCompliant:
            // If target already passes on Light background, keep Light exact; else apply minimal nudge.
            let lightPasses = WCAG.contrastRatio(fg: target, bg: lightBG) >= 3.0
            if lightPasses {
                light = target
            } else {
                light = target.adjust(brightness: baseLightOffset - clampedBias * biasScale)
                light = ensureUIContrast(light, bg: lightBG)
            }
            // Dark uses the usual offset guardrailed path
            dark  = target.adjust(brightness: baseDarkOffset  + clampedBias * biasScale)
            dark  = ensureUIContrast(dark,  bg: darkBG)

        case .brandLockedLight:
            // Always keep Light = exact brand color (even if it fails); only Dark adjusts/guardrails.
            light = target
            dark  = target.adjust(brightness: baseDarkOffset  + clampedBias * biasScale)
            dark  = ensureUIContrast(dark,  bg: darkBG)
        }

        // Preserve intuitive ordering (Dark twin should be lighter than Light twin)
        if luminance(dark) <= luminance(light) {
            light = nudge(color: light, direction: .darker, steps: 1)
            dark  = nudge(color: dark,  direction: .lighter, steps: 1)
        }

        // Optional: compute your text badges (unchanged)
        let white = RGBA(r: 1, g: 1, b: 1, a: 1)
        let bothPassText =
            WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: light)) &&
            WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: dark))

        return DerivedPair(target: target, light: light, dark: dark, wcagPass: bothPassText)
    }

    // MARK: - Helpers

    /// Iteratively nudge until the color meets a minimum contrast ratio vs. a background.
    // Replace your ensureContrastVSBackground with this:
    private static func ensureContrast(color start: RGBA,
                                       bg: RGBA,
                                       preferLighter: Bool? = nil,
                                       minRatio: Double) -> RGBA {
        // Decide a sensible first direction: if the background is dark, lighten; if light, darken.
        let bgIsDark = luminance(bg) < 0.5
        let firstLighter = preferLighter ?? bgIsDark

        // Try once in the preferred direction; if we don't hit the target, try the opposite and keep the best.
        let attempt1 = climbContrast(from: start, bg: bg, wantLighter: firstLighter, minRatio: minRatio)
        if attempt1.hit { return attempt1.color }

        let attempt2 = climbContrast(from: start, bg: bg, wantLighter: !firstLighter, minRatio: minRatio)
        return (attempt2.ratio > attempt1.ratio) ? attempt2.color : attempt1.color
    }

    // Small hill-climb with a stall guard; never walks forever.
    private static func climbContrast(from start: RGBA,
                                      bg: RGBA,
                                      wantLighter: Bool,
                                      minRatio: Double) -> (color: RGBA, ratio: Double, hit: Bool) {
        var c = start
        var best = start
        var bestRatio = WCAG.contrastRatio(fg: c, bg: bg)

        if bestRatio >= minRatio { return (start, bestRatio, true) }

        let step = wantLighter ? 0.02 : -0.02
        let maxSteps = 48
        var stallCount = 0
        let epsilon = 1e-3  // ignore tiny floating noise

        for _ in 0..<maxSteps {
            c = c.adjust(brightness: step)
            let r = WCAG.contrastRatio(fg: c, bg: bg)

            if r > bestRatio + epsilon {
                bestRatio = r
                best = c
                stallCount = 0
            } else {
                stallCount += 1
            }

            if r >= minRatio { return (c, r, true) }
            if stallCount >= 6 { break } // bail if not improving
        }
        return (best, bestRatio, false)
    }

    private enum Direction { case lighter, darker }
    private static func nudge(color: RGBA, direction: Direction, steps: Int) -> RGBA {
        var c = color
        for _ in 0..<steps {
            c = c.adjust(brightness: direction == .lighter ? 0.02 : -0.02)
        }
        return c
    }

    /// Relative luminance proxy (sRGB → linearized) for ordering.
    private static func luminance(_ c: RGBA) -> Double {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v/12.92 : pow((v + 0.055)/1.055, 2.4) }
        let R = lin(c.r), G = lin(c.g), B = lin(c.b)
        return 0.2126*R + 0.7152*G + 0.0722*B
    }

    // Expose for previews/tests if helpful
    static var systemBackgrounds: (light: RGBA, dark: RGBA) { (lightBG, darkBG) }
}


// MARK: - Metrics (text/background ratios + summary)
extension DerivedPairEngine {
    private static let textAA: Double = 4.5
    private static let bgUI: Double  = 3.0

    struct PairMetrics {
        struct Twin {
            let text: Double   // white-on-color text contrast
            let bg: Double     // color vs system background
            var pass: Bool { text >= textAA && bg >= bgUI }
        }
        let light: Twin
        let dark: Twin
        var overallPass: Bool { light.pass && dark.pass }

        var overallSummary: String {
            if overallPass { return "Both PASS" }
            // Explain the first failing reason (most actionable)
            if dark.text < textAA { return "Both FAIL — Dark text \(fmt(dark.text))× < 4.5×" }
            if light.text < textAA { return "Both FAIL — Light text \(fmt(light.text))× < 4.5×" }
            if dark.bg   < bgUI   { return "Both FAIL — Dark bg \(fmt(dark.bg))× < 3.0×" }
            return                 "Both FAIL — Light bg \(fmt(light.bg))× < 3.0×"
        }
    }

    static func metrics(for pair: DerivedPair) -> PairMetrics {
        let white = RGBA(r: 1, g: 1, b: 1, a: 1)
        let lightText = WCAG.contrastRatio(fg: white,      bg: pair.light)
        let darkText  = WCAG.contrastRatio(fg: white,      bg: pair.dark)
        let lightBg   = WCAG.contrastRatio(fg: pair.light, bg: lightBG)
        let darkBg    = WCAG.contrastRatio(fg: pair.dark,  bg: darkBG)
        return PairMetrics(
            light: .init(text: lightText, bg: lightBg),
            dark:  .init(text: darkText,  bg: darkBg)
        )
    }

    private static func fmt(_ x: Double) -> String { String(format: "%.2f", x) }
}

// MARK: - Small utilities

extension Comparable {
    func clamped(to r: ClosedRange<Self>) -> Self { min(max(self, r.lowerBound), r.upperBound) }
}

// PairPolicy.swift
enum PairPolicy: String, CaseIterable, Codable, Sendable {
    /// Default “balanced”: both twins may move, with background contrast guardrails.
    case guardrailed

    /// Keep Light exactly equal to the brand color **if** it already passes; otherwise nudge it.
    case exactLightIfCompliant

    /// Force Light to remain exactly the brand color regardless of guardrails; only Dark adjusts.
    /// (Useful for demos/brand-lock scenarios; expect accessibility badges to reflect failures.)
    case brandLockedLight
}

extension PairPolicy {
    /// Convenience for the UI toggle: ON => exact when safe, OFF => balanced guardrails
    static func fromToggle(_ keepLightExact: Bool) -> PairPolicy {
        keepLightExact ? .exactLightIfCompliant : .guardrailed
    }
}
