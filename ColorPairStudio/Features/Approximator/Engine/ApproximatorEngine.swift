//
//  ApproximatorEngine.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation
import SwiftUI

struct ApproximatorEngine {
    struct Base: Identifiable { let id = UUID(); let name: String; let rgba: RGBA; let color: Color }
    // Curated SwiftUI bases
    let bases: [Base] = [
        Base(name: ".blue", rgba: .init(r: 0.00, g: 0.48, b: 1.00, a: 1), color: .blue),
        Base(name: ".indigo", rgba: .init(r: 0.30, g: 0.34, b: 0.86, a: 1), color: .indigo),
        Base(name: ".teal", rgba: .init(r: 0.35, g: 0.78, b: 0.98, a: 1), color: .teal),
        Base(name: ".mint", rgba: .init(r: 0.65, g: 0.88, b: 0.72, a: 1), color: .mint),
        Base(name: ".green", rgba: .init(r: 0.20, g: 0.80, b: 0.20, a: 1), color: .green),
        Base(name: ".yellow", rgba: .init(r: 1.00, g: 0.84, b: 0.00, a: 1), color: .yellow),
        Base(name: ".orange", rgba: .init(r: 1.00, g: 0.60, b: 0.00, a: 1), color: .orange),
        Base(name: ".red", rgba: .init(r: 1.00, g: 0.23, b: 0.19, a: 1), color: .red),
        Base(name: ".pink", rgba: .init(r: 1.00, g: 0.17, b: 0.33, a: 1), color: .pink),
        Base(name: ".purple", rgba: .init(r: 0.69, g: 0.32, b: 0.87, a: 1), color: .purple),
        Base(name: ".brown", rgba: .init(r: 0.64, g: 0.50, b: 0.39, a: 1), color: .brown),
        Base(name: ".gray", rgba: .init(r: 0.56, g: 0.56, b: 0.58, a: 1), color: .gray)
    ]
    
    // ApproximatorEngine.swift
    // ApproximatorEngine.swift
    func approximate(to target: RGBA) -> ApproximatedOutput {
        // 1) Find nearest system base (same logic you had)
        let tLab = target.toLab()
        guard let nearest = bases.min(by: {
            DeltaE.ciede2000($0.rgba.toLab(), tLab) < DeltaE.ciede2000($1.rgba.toLab(), tLab)
        }) else {
            // Fallback if `bases` were ever empty
            let fallbackToken: SystemColorToken = .blue
            let white = RGBA(r: 1, g: 1, b: 1, a: 1)
            let wcag = WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: target))
            return ApproximatedOutput(
                target: target,
                base: fallbackToken,
                hueDegrees: 0.0,
                saturation: 1.0,
                brightness: 0.0,
                deltaE: 0.0,
                wcagPass: wcag
            )
        }

        // 2) Convert the nearest base name (".indigo", "indigo", or "Color.indigo") to a token
        let baseToken = SystemColorToken(normalizing: nearest.name) ?? .blue

        // 3) Start with identity tweaks (sliders in the UI will change these live)
        let hueDegrees: Double = 0.0
        let saturation: Double = 1.0
        let brightness: Double = 0.0

        // 4) Metrics for ΔE and initial WCAG badge (white-on-color)
        let deltaE = DeltaE.ciede2000(nearest.rgba.toLab(), tLab)
        let white = RGBA(r: 1, g: 1, b: 1, a: 1)
        let wcagPass = WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: nearest.rgba))

        // 5) Return the new token-based output (no more Color..red)
        return ApproximatedOutput(
            target: target,
            base: baseToken,
            hueDegrees: hueDegrees,
            saturation: saturation,
            brightness: brightness,
            deltaE: deltaE,
            wcagPass: wcagPass
        )
    }
}
