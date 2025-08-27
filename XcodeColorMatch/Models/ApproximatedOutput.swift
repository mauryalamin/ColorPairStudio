//
//  ApproximatedOutput.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation
import SwiftUI

struct ApproximatedOutput {
    let target: RGBA
    let baseName: String
    let baseColor: Color
    let baseRGBA: RGBA
    let hueDegrees: Double
    let saturation: Double
    let brightness: Double
    let deltaE: Double
    let wcagPass: Bool
}

extension ApproximatedOutput {

    static let samplePass: ApproximatedOutput = {
        // Target brand-ish blue
        let target   = RGBA(r: 76/255, g: 111/255, b: 175/255, a: 1)

        // Nearest system base we want to demo
        let baseName = ".indigo"
        let baseRGBA = RGBA(r: 0.30, g: 0.34, b: 0.86, a: 1) // matches your engine's indigo
        let baseColor: Color = .indigo

        // Safe, subtle adjustments
        let hue = 8.0
        let sat = 0.95
        let bri = 0.04

        // Compute live delta vs adjusted color
        let adjusted = baseRGBA.applying(hueDegrees: hue, satMultiplier: sat, brightnessDelta: bri)
        let delta = target.rgbDistance(to: adjusted)

        return ApproximatedOutput(
            target: target,
            baseName: baseName,
            baseColor: baseColor,
            baseRGBA: baseRGBA,              // NEW
            hueDegrees: hue,
            saturation: sat,
            brightness: bri,
            deltaE: delta,
            wcagPass: true                   // stub until real contrast check
        )
    }()

    static let sampleFail: ApproximatedOutput = {
        // Target strong red
        let target   = RGBA(r: 220/255, g: 60/255, b: 60/255, a: 1)

        let baseName = ".red"
        let baseRGBA = RGBA(r: 1.00, g: 0.23, b: 0.19, a: 1)  // engine's red
        let baseColor: Color = .red

        // No adjustments (to demo a worse match)
        let hue = 0.0
        let sat = 1.0
        let bri = 0.0

        let adjusted = baseRGBA.applying(hueDegrees: hue, satMultiplier: sat, brightnessDelta: bri)
        let delta = target.rgbDistance(to: adjusted)

        return ApproximatedOutput(
            target: target,
            baseName: baseName,
            baseColor: baseColor,
            baseRGBA: baseRGBA,              // NEW
            hueDegrees: hue,
            saturation: sat,
            brightness: bri,
            deltaE: delta,
            wcagPass: false                  // stub until real contrast check
        )
    }()
}

