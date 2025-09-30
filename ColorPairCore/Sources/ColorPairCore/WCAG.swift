//
//  WCAG.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/28/25.
//

import Foundation

public enum WCAG {
    /// sRGB (0...1) → relative luminance per WCAG
    private static func relLuminance(_ r: Double, _ g: Double, _ b: Double) -> Double {
        func toLinear(_ c: Double) -> Double {
            c <= 0.04045 ? (c/12.92) : pow((c + 0.055)/1.055, 2.4)
        }
        let R = toLinear(r), G = toLinear(g), B = toLinear(b)
        return 0.2126*R + 0.7152*G + 0.0722*B
    }

    /// Contrast ratio (>=1 ... 21)
    public static func contrastRatio(fg: RGBA, bg: RGBA) -> Double {
        let L1 = relLuminance(fg.r, fg.g, fg.b)
        let L2 = relLuminance(bg.r, bg.g, bg.b)
        let (light, dark) = (max(L1, L2), min(L1, L2))
        return (light + 0.05) / (dark + 0.05)
    }

    public static func passesAA(normalText ratio: Double) -> Bool { ratio >= 4.5 }
    public static func passesAA(largeText ratio: Double) -> Bool { ratio >= 3.0 } // ≥18pt or 14pt bold
}
