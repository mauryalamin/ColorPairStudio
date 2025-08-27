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
    
    func approximate(to target: RGBA) -> ApproximatedOutput {
        // Pick nearest base by simple RGB distance (ΔE stubbed)
        let nearest = bases.min(by: { $0.rgba.rgbDistance(to: target) < $1.rgba.rgbDistance(to: target) })!
        // Placeholder tiny nudges – will be replaced by guard‑ranged search
        let hueDegrees = 8.0
        let saturation = 0.95
        let brightness = 0.04
        let deltaE = target.rgbDistance(to: nearest.rgba) // TODO: swap with ΔE
        let wcagPass = true // TODO: compute WCAG on previews
        return ApproximatedOutput(target: target,
                                  baseName: nearest.name,
                                  baseColor: nearest.color,
                                  baseRGBA: nearest.rgba, 
                                  hueDegrees: hueDegrees,
                                  saturation: saturation,
                                  brightness: brightness,
                                  deltaE: deltaE,
                                  wcagPass: wcagPass)
    }
}
