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
    static func derive(from target: RGBA, bias: Double = 0.0) -> DerivedPair {
        let clampedBias = bias.clamped(to: biasRange)

        // 1) Start with sensible base offsets (tuned to feel "Mac-right")
        let baseLightOffset = -0.08   // darken for light mode background
        let baseDarkOffset  =  0.10   // lighten for dark mode background

        // 2) Apply symmetric bias around those bases
        var light = target.adjust(brightness: baseLightOffset - clampedBias * biasScale)
        var dark  = target.adjust(brightness: baseDarkOffset  + clampedBias * biasScale)

        // 3) Ensure contrast vs system backgrounds (≈ UI 3:1 guardrail)
        light = ensureContrast(color: light, bg: lightBG, minRatio: 3.0)
        dark  = ensureContrast(color: dark,  bg: darkBG,  minRatio: 3.0)

        // 4) Preserve intuitive ordering (the "dark-mode twin" should be lighter than the light-mode twin)
        if luminance(dark) <= luminance(light) {
            // Minimal opposing nudge to re-establish ordering
            light = nudge(color: light, direction: .darker, steps: 1)
            dark  = nudge(color: dark,  direction: .lighter, steps: 1)
        }

        // 5) Optional: white-on-color WCAG badge for previews
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

// MARK: - Small utilities

extension Comparable {
    func clamped(to r: ClosedRange<Self>) -> Self { min(max(self, r.lowerBound), r.upperBound) }
}
