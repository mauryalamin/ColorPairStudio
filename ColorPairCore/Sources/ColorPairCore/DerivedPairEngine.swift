//
//  DerivedPairEngine.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

public enum DerivedPairEngine {

    // MARK: - Config (core-only; no AppKit/SwiftUI)
    public struct Config: Sendable {
        public var lightBG: RGBA
        public var darkBG:  RGBA
        public init(lightBG: RGBA, darkBG: RGBA) {
            self.lightBG = lightBG
            self.darkBG  = darkBG
        }
    }

    /// Immutable default used by pure functions & tests.
    public static let defaultConfig = Config(
        lightBG: RGBA(r: 1,    g: 1,    b: 1,    a: 1),     // white
        darkBG:  RGBA(r: 0.12, g: 0.12, b: 0.12, a: 1)      // ~#1F1F1F
    )

    /// Mutable current config, **main-actor isolated** for safety. Your app updates this at launch.
    @MainActor
    public static var config: Config = defaultConfig

    // MARK: - Bias & thresholds
    private static let biasRange: ClosedRange<Double> = -0.25...0.25
    private static let biasScale: Double = 1.0

    private static let textAA: Double = 4.5
    private static let bgUI:  Double = 3.0

    // MARK: - API (pure; defaults to defaultConfig)
    /// Derive Light/Dark twins from a target color (pure; no global reads).
    /// Positive `bias` => lighter Dark twin & darker Light twin (more separation).
    public static func derive(
        from target: RGBA,
        bias: Double = 0.0,
        policy: PairPolicy = .exactLightIfCompliant,
        using cfg: Config = defaultConfig
    ) -> DerivedPair {

        let clampedBias = bias.clamped(to: biasRange)

        // Tuned base offsets (feel “Mac-right”)
        let baseLightOffset = -0.08    // darken on Light-mode background
        let baseDarkOffset  =  0.10    // lighten on Dark-mode background

        // Helpers
        func ensureUIContrast(_ c: RGBA, bg: RGBA) -> RGBA {
            ensureContrast(color: c, bg: bg, minRatio: 3.0)  // ~UI legibility guardrail
        }

        // Start with defaults; then fill per policy
        var light = target
        var dark  = target

        switch policy {
        case .guardrailed:
            light = target.adjust(brightness: baseLightOffset - clampedBias * biasScale)
            dark  = target.adjust(brightness: baseDarkOffset  + clampedBias * biasScale)
            light = ensureUIContrast(light, bg: cfg.lightBG)
            dark  = ensureUIContrast(dark,  bg: cfg.darkBG)

        case .exactLightIfCompliant:
            // Keep Light exact if it already passes vs the Light background
            let lightPasses = WCAG.contrastRatio(fg: target, bg: cfg.lightBG) >= 3.0
            if lightPasses {
                light = target
            } else {
                light = target.adjust(brightness: baseLightOffset - clampedBias * biasScale)
                light = ensureUIContrast(light, bg: cfg.lightBG)
            }
            dark  = target.adjust(brightness: baseDarkOffset  + clampedBias * biasScale)
            dark  = ensureUIContrast(dark,  bg: cfg.darkBG)

        case .brandLockedLight:
            // Keep Light exact regardless; only Dark adjusts/guardrails
            light = target
            dark  = target.adjust(brightness: baseDarkOffset  + clampedBias * biasScale)
            dark  = ensureUIContrast(dark,  bg: cfg.darkBG)
        }

        // Preserve intuitive ordering: the “dark-mode twin” should be lighter
        if luminance(dark) <= luminance(light) {
            light = nudge(color: light, direction: .darker, steps: 1)
            dark  = nudge(color: dark,  direction: .lighter, steps: 1)
        }

        // Optional: white-on-color WCAG badge for previews
        let white = RGBA(r: 1, g: 1, b: 1, a: 1)
        let bothPass =
            WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: light)) &&
            WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: dark))

        return DerivedPair(target: target, light: light, dark: dark, wcagPass: bothPass)
    }

    /// Convenience: use the current (mutable) config safely on the main actor.
    @MainActor
    public static func deriveUsingCurrentConfig(
        from target: RGBA,
        bias: Double = 0.0,
        policy: PairPolicy = .exactLightIfCompliant
    ) -> DerivedPair {
        derive(from: target, bias: bias, policy: policy, using: config)
    }

    // MARK: - Metrics
    public struct PairMetrics: Sendable {
        public struct Twin: Sendable {
            public let text: Double   // white-on-color text contrast
            public let bg:   Double   // color vs system background
            public var pass: Bool {
                text >= DerivedPairEngine.textAA && bg >= DerivedPairEngine.bgUI
            }
        }
        public let light: Twin
        public let dark:  Twin
        public var overallPass: Bool { light.pass && dark.pass }

        public var overallSummary: String {
            if overallPass { return "Both PASS" }
            // Explain the first failing reason (most actionable)
            if dark.text < DerivedPairEngine.textAA { return "Both FAIL — Dark text \(fmt(dark.text))× < 4.5×" }
            if light.text < DerivedPairEngine.textAA { return "Both FAIL — Light text \(fmt(light.text))× < 4.5×" }
            if dark.bg   < DerivedPairEngine.bgUI   { return "Both FAIL — Dark bg \(fmt(dark.bg))× < 3.0×" }
            return                                      "Both FAIL — Light bg \(fmt(light.bg))× < 3.0×"
        }
    }

    public static func metrics(
        for pair: DerivedPair,
        using cfg: Config = defaultConfig
    ) -> PairMetrics {
        let white   = RGBA(r: 1, g: 1, b: 1, a: 1)
        let lightTx = WCAG.contrastRatio(fg: white,      bg: pair.light)
        let darkTx  = WCAG.contrastRatio(fg: white,      bg: pair.dark)
        let lightBG = WCAG.contrastRatio(fg: pair.light, bg: cfg.lightBG)
        let darkBG  = WCAG.contrastRatio(fg: pair.dark,  bg: cfg.darkBG)
        return PairMetrics(
            light: .init(text: lightTx, bg: lightBG),
            dark:  .init(text: darkTx,  bg: darkBG)
        )
    }

    @MainActor
    public static func metricsUsingCurrentConfig(for pair: DerivedPair) -> PairMetrics {
        metrics(for: pair, using: config)
    }

    // MARK: - Internal helpers (core math only)

    private static func fmt(_ x: Double) -> String { String(format: "%.2f", x) }

    private enum Direction { case lighter, darker }

    private static func nudge(color: RGBA, direction: Direction, steps: Int) -> RGBA {
        var c = color
        for _ in 0..<steps { c = c.adjust(brightness: direction == .lighter ? 0.02 : -0.02) }
        return c
    }

    /// Iteratively nudge until the color meets a minimum contrast ratio vs. a background.
    private static func ensureContrast(
        color start: RGBA,
        bg: RGBA,
        preferLighter: Bool? = nil,
        minRatio: Double
    ) -> RGBA {
        // Sensible first direction: if the background is dark, lighten; if light, darken.
        let bgIsDark = luminance(bg) < 0.5
        let firstLighter = preferLighter ?? bgIsDark

        // Try once in the preferred direction; if not enough, try the opposite and keep the best.
        let attempt1 = climbContrast(from: start, bg: bg, wantLighter: firstLighter, minRatio: minRatio)
        if attempt1.hit { return attempt1.color }

        let attempt2 = climbContrast(from: start, bg: bg, wantLighter: !firstLighter, minRatio: minRatio)
        return (attempt2.ratio > attempt1.ratio) ? attempt2.color : attempt1.color
    }

    // Small hill-climb with a stall guard; never walks forever.
    private static func climbContrast(
        from start: RGBA,
        bg: RGBA,
        wantLighter: Bool,
        minRatio: Double
    ) -> (color: RGBA, ratio: Double, hit: Bool) {
        var c = start
        var best = start
        var bestRatio = WCAG.contrastRatio(fg: c, bg: bg)
        if bestRatio >= minRatio { return (start, bestRatio, true) }

        let step = wantLighter ? 0.02 : -0.02
        let maxSteps = 48
        var stallCount = 0
        let epsilon = 1e-3  // ignore tiny float noise

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

    /// Relative luminance proxy (sRGB → linearized) for ordering.
    private static func luminance(_ c: RGBA) -> Double {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v/12.92 : pow((v + 0.055)/1.055, 2.4) }
        let R = lin(c.r), G = lin(c.g), B = lin(c.b)
        return 0.2126*R + 0.7152*G + 0.0722*B
    }
}

// Keep one copy of this in core (remove duplicates elsewhere)
public extension Comparable {
    func clamped(to r: ClosedRange<Self>) -> Self { min(max(self, r.lowerBound), r.upperBound) }
}

// MARK: - Policy (public, in core)
public enum PairPolicy: String, CaseIterable, Codable, Sendable {
    case guardrailed
    case exactLightIfCompliant
    case brandLockedLight
}

public extension PairPolicy {
    /// Convenience for the UI toggle: ON => exact when safe, OFF => balanced guardrails
    static func fromToggle(_ keepLightExact: Bool) -> PairPolicy {
        keepLightExact ? .exactLightIfCompliant : .guardrailed
    }
}
