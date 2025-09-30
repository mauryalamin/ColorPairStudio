//
//  DerivedPair.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

// ColorPairCore/Sources/ColorPairCore/DerivedPair.swift
public struct DerivedPair: Codable, Sendable {
    public let target: RGBA
    public let light: RGBA
    public let dark: RGBA
    public let wcagPass: Bool

    public init(target: RGBA, light: RGBA, dark: RGBA, wcagPass: Bool) {
        self.target = target
        self.light = light
        self.dark = dark
        self.wcagPass = wcagPass
    }
}

public extension DerivedPair {
    static let sample: DerivedPair = {
        let target = RGBA(r: 76/255, g: 111/255, b: 175/255, a: 1)
        return DerivedPairEngine.derive(from: target)
    }()
}

extension DerivedPair {
    static func sampleComputed() -> DerivedPair {
        let target = RGBA(r: 0.3, g: 0.5, b: 0.7, a: 1)
        let pair   = DerivedPairEngine.derive(from: target, bias: 0)
        let white  = RGBA(r: 1, g: 1, b: 1, a: 1)

        let lightCR = WCAG.contrastRatio(fg: white, bg: pair.light)
        let darkCR  = WCAG.contrastRatio(fg: white, bg: pair.dark)
        let pass    = (lightCR >= 4.5) && (darkCR >= 4.5)   // AA body text threshold

        return DerivedPair(target: target, light: pair.light, dark: pair.dark, wcagPass: pass)
    }
}
