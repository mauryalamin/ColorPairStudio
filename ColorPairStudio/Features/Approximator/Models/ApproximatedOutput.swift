//
//  ApproximatedOutput.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation
import SwiftUI

// ApproximatedOutput.swift
import Foundation

struct ApproximatedOutput: Codable, Sendable {
    let target: RGBA
    let base: SystemColorToken            // ← NEW: source of truth (no leading dot)
    let hueDegrees: Double
    let saturation: Double
    let brightness: Double
    let deltaE: Double
    let wcagPass: Bool

    // Back-compat shim if old code still sets `baseName` like ".red"
    @available(*, deprecated, message: "Use `base` (SystemColorToken) instead.")
    var baseName: String { ".\(base.rawValue)" }

    // Convenience used by Exporter/UI if needed
    var swiftBaseExpr: String { base.swiftExpr }
    
    // SwiftUI.Color for previews
    var baseColor: Color { base.swiftUIColor }

    // TEMP initializer to bridge old call sites that still pass `.baseName`
    @available(*, deprecated, message: "Migrate call sites to pass `base: SystemColorToken`.")
    init(target: RGBA,
         baseName: String,
         hueDegrees: Double,
         saturation: Double,
         brightness: Double,
         deltaE: Double,
         wcagPass: Bool)
    {
        self.target = target
        self.base = SystemColorToken(normalizing: baseName) ?? .blue // safe default
        self.hueDegrees = hueDegrees
        self.saturation = saturation
        self.brightness = brightness
        self.deltaE = deltaE
        self.wcagPass = wcagPass
    }

    // Preferred initializer
    init(target: RGBA,
         base: SystemColorToken,
         hueDegrees: Double,
         saturation: Double,
         brightness: Double,
         deltaE: Double,
         wcagPass: Bool)
    {
        self.target = target
        self.base = base
        self.hueDegrees = hueDegrees
        self.saturation = saturation
        self.brightness = brightness
        self.deltaE = deltaE
        self.wcagPass = wcagPass
    }
}

// MARK: - Samples (updated for SystemColorToken-based output)
import SwiftUI

extension ApproximatedOutput {

    static let samplePass: ApproximatedOutput = {
        // Target brand-ish blue
        let target = RGBA(r: 76/255, g: 111/255, b: 175/255, a: 1)

        // Nearest system token we want to demo
        let baseToken: SystemColorToken = .indigo

        // sRGB for the chosen system color (approx for demo/math)
        let baseRGBA = RGBA(r: 0.30, g: 0.34, b: 0.86, a: 1)

        // Safe, subtle adjustments
        let hue: Double = 8.0
        let sat: Double = 0.95
        let bri: Double = 0.04

        // Compute adjusted color to drive ΔE & WCAG badge
        let adjusted = baseRGBA.applying(hueDegrees: hue,
                                         satMultiplier: sat,
                                         brightnessDelta: bri)
        let delta = target.rgbDistance(to: adjusted)
        let white = RGBA(r: 1, g: 1, b: 1, a: 1)
        let wcag = WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: adjusted))

        return ApproximatedOutput(
            target: target,
            base: baseToken,          // ← NEW: token, not ".indigo" string
            hueDegrees: hue,
            saturation: sat,
            brightness: bri,
            deltaE: delta,
            wcagPass: wcag
        )
    }()

    static let sampleFail: ApproximatedOutput = {
        // A light brand tone that will fail white-on-color AA (for demo)
        let target = RGBA(r: 1.00, g: 0.95, b: 0.60, a: 1)   // pale yellow

        let baseToken: SystemColorToken = .yellow
        let baseRGBA  = RGBA(r: 1.00, g: 0.84, b: 0.20, a: 1)

        // Minimal/identity tweaks still likely produce a fail for white text
        let hue: Double = 0.0
        let sat: Double = 1.0
        let bri: Double = 0.00

        let adjusted = baseRGBA.applying(hueDegrees: hue,
                                         satMultiplier: sat,
                                         brightnessDelta: bri)
        let delta = target.rgbDistance(to: adjusted)
        let white = RGBA(r: 1, g: 1, b: 1, a: 1)
        let wcag = WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: adjusted)) // will be false

        return ApproximatedOutput(
            target: target,
            base: baseToken,
            hueDegrees: hue,
            saturation: sat,
            brightness: bri,
            deltaE: delta,
            wcagPass: wcag
        )
    }()
}

extension ApproximatedOutput {
    var baseRGBA: RGBA { base.rgbaApprox }
}
