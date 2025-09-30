//
//  ApproximatedOutput.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

// ApproximatedOutput.swift
import Foundation


public struct ApproximatedOutput: Codable, Sendable {
    public let target: RGBA
    public let base: SystemColorToken
    public let hueDegrees: Double
    public let saturation: Double
    public let brightness: Double
    public let deltaE: Double
    public let wcagPass: Bool

    // Convenience used by Exporter/UI
    public var swiftBaseExpr: String { base.swiftExpr }

    private enum CodingKeys: String, CodingKey {
        case target, base, baseName, hueDegrees, saturation, brightness, deltaE, wcagPass
    }

    // Preferred init for new code
    public init(target: RGBA,
         base: SystemColorToken,
         hueDegrees: Double,
         saturation: Double,
         brightness: Double,
         deltaE: Double,
         wcagPass: Bool) {
        self.target = target
        self.base = base
        self.hueDegrees = hueDegrees
        self.saturation = saturation
        self.brightness = brightness
        self.deltaE = deltaE
        self.wcagPass = wcagPass
    }

    // ✅ Custom decode: supports new `base` and legacy `baseName`
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        target     = try c.decode(RGBA.self,    forKey: .target)

        if let tok = try? c.decode(SystemColorToken.self, forKey: .base) {
            base = tok
        } else if let legacy = try? c.decode(String.self, forKey: .baseName),
                  let tok = SystemColorToken(normalizing: legacy) {
            base = tok
        } else {
            // Choose: either fail hard or pick a safe default
            // throw DecodingError.keyNotFound(CodingKeys.base, .init(codingPath: c.codingPath, debugDescription: "Missing `base` or `baseName`"))
            base = .blue
        }

        hueDegrees = try c.decode(Double.self, forKey: .hueDegrees)
        saturation = try c.decode(Double.self, forKey: .saturation)
        brightness = try c.decode(Double.self, forKey: .brightness)
        deltaE     = try c.decode(Double.self, forKey: .deltaE)
        wcagPass   = try c.decode(Bool.self,   forKey: .wcagPass)
    }

    // ✅ Custom encode (writes new `base`; optionally echoes legacy `baseName` during a transition)
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(target,     forKey: .target)
        try c.encode(base,       forKey: .base)                 // new field
        try c.encode(hueDegrees, forKey: .hueDegrees)
        try c.encode(saturation, forKey: .saturation)
        try c.encode(brightness, forKey: .brightness)
        try c.encode(deltaE,     forKey: .deltaE)
        try c.encode(wcagPass,   forKey: .wcagPass)
        // Optional: keep for a version or two, then remove
        try c.encode(".\(base.rawValue)", forKey: .baseName)
    }
}

// MARK: - Samples (updated for SystemColorToken-based output)
import SwiftUI

public extension ApproximatedOutput {

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

public extension ApproximatedOutput {
    /// sRGB RGBA for ΔE/contrast math
    var baseRGBA: RGBA { base.rgbaApprox }
}
