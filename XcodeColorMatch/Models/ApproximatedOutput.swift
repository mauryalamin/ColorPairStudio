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
    let hueDegrees: Double
    let saturation: Double
    let brightness: Double
    let deltaE: Double
    let wcagPass: Bool
}

extension ApproximatedOutput {
    static let samplePass = ApproximatedOutput(
        target: RGBA(r: 76/255, g: 111/255, b: 175/255, a: 1),
        baseName: ".indigo",
        baseColor: .indigo,
        hueDegrees: 8,
        saturation: 0.95,
        brightness: 0.04,
        deltaE: 1.6,
        wcagPass: true
    )

    static let sampleFail = ApproximatedOutput(
        target: RGBA(r: 220/255, g: 60/255, b: 60/255, a: 1),
        baseName: ".red",
        baseColor: .red,
        hueDegrees: 0,
        saturation: 1.0,
        brightness: 0.0,
        deltaE: 3.2,
        wcagPass: false
    )
}
