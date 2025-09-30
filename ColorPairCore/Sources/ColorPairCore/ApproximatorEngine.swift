//
//  ApproximatorEngine.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

public struct ApproximatorEngine {
    public init() {}

    // Curated SwiftUI bases, represented as tokens (no SwiftUI types in core)
    private static let bases: [SystemColorToken] = [
        .blue, .indigo, .teal, .mint, .green, .yellow, .orange,
        .red, .pink, .purple, .brown, .gray, .cyan
    ]

    /// Returns the nearest system base and default (no-op) adjustments.
    public func approximate(to target: RGBA) -> ApproximatedOutput {
        let tLab = target.toLab()

        // Find nearest by ΔE2000 in LAB space
        let nearest = Self.bases.min { a, b in
            DeltaE.ciede2000(a.rgbaApprox.toLab(), tLab) <
            DeltaE.ciede2000(b.rgbaApprox.toLab(), tLab)
        } ?? .blue

        let delta = DeltaE.ciede2000(nearest.rgbaApprox.toLab(), tLab)

        // Start with no tweaks; UI sliders apply live changes
        let hueDegrees = 0.0
        let saturation = 1.0
        let brightness = 0.0

        // White-on-color contrast for the initial badge
        let white = RGBA(r: 1, g: 1, b: 1, a: 1)
        let wcagPass = WCAG.passesAA(
            normalText: WCAG.contrastRatio(fg: white, bg: nearest.rgbaApprox)
        )

        return ApproximatedOutput(
            target: target,
            base: nearest,                 // ← token, not Color
            hueDegrees: hueDegrees,
            saturation: saturation,
            brightness: brightness,
            deltaE: delta,
            wcagPass: wcagPass
        )
    }
}
