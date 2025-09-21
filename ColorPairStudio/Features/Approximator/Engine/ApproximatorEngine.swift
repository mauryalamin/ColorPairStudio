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
    func approximate(to target: RGBA) -> ApproximatedOutput {
        let tLab = target.toLab()
        let nearest = bases.min { a, b in
            DeltaE.ciede2000(a.rgba.toLab(), tLab) < DeltaE.ciede2000(b.rgba.toLab(), tLab)
        }!

        // Start with no nudges; the view’s sliders apply live changes
        let hueDegrees = 0.0, saturation = 1.0, brightness = 0.0
        let deltaE = DeltaE.ciede2000(nearest.rgba.toLab(), tLab)

        // White-on-color contrast for the initial badge
        let white = RGBA(r: 1, g: 1, b: 1, a: 1)
        let wcagPass = WCAG.passesAA(normalText: WCAG.contrastRatio(fg: white, bg: nearest.rgba))

        return ApproximatedOutput(
            target: target,
            baseName: nearest.name,
            baseColor: nearest.color,
            baseRGBA: nearest.rgba,
            hueDegrees: hueDegrees,
            saturation: saturation,
            brightness: brightness,
            deltaE: deltaE,
            wcagPass: wcagPass
        )
    }
}
