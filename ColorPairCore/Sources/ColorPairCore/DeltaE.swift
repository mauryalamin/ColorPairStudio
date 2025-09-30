//
//  DeltaE.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/28/25.
//

import Foundation

public struct Lab { var L: Double; var a: Double; var b: Double }

// sRGB → Lab helpers
extension RGBA {
    // sRGB → XYZ (D65)
    public func srgbToXYZ() -> (X: Double, Y: Double, Z: Double) {
        func toLinear(_ c: Double) -> Double { c <= 0.04045 ? (c/12.92) : pow((c + 0.055)/1.055, 2.4) }
        let R = toLinear(r), G = toLinear(g), B = toLinear(b)
        let X = 0.4124564*R + 0.3575761*G + 0.1804375*B
        let Y = 0.2126729*R + 0.7151522*G + 0.0721750*B
        let Z = 0.0193339*R + 0.1191920*G + 0.9503041*B
        return (X, Y, Z)
    }
    // XYZ → Lab (D65/2°)
    public func toLab() -> Lab {
        let xyz = srgbToXYZ()
        // D65 reference white
        let Xr = 0.95047, Yr = 1.00000, Zr = 1.08883
        func f(_ t: Double) -> Double {
            let d = pow(6.0/29.0, 3.0)
            if t > d { return pow(t, 1.0/3.0) }
            let c = pow(29.0/6.0, 2.0) / 3.0
            return c*t + 4.0/29.0
        }
        let fx = f(xyz.X / Xr), fy = f(xyz.Y / Yr), fz = f(xyz.Z / Zr)
        return Lab(L: 116*fy - 16, a: 500*(fx - fy), b: 200*(fy - fz))
    }
}

public enum DeltaE {
    /// CIEDE2000 color difference (ΔE00)
    public static func ciede2000(_ A: Lab, _ B: Lab) -> Double {
        let (L1, a1, b1) = (A.L, A.a, A.b)
        let (L2, a2, b2) = (B.L, B.a, B.b)
        let kL = 1.0, kC = 1.0, kH = 1.0
        let deg2rad = Double.pi / 180.0

        // Chroma
        let C1 = sqrt(a1*a1 + b1*b1)
        let C2 = sqrt(a2*a2 + b2*b2)
        let avgC = (C1 + C2) / 2.0

        // Compensation factor G
        let pow7 = pow(avgC, 7.0)
        let G = 0.5 * (1.0 - sqrt(pow7 / (pow7 + pow(25.0, 7.0))))

        // Adjusted a*
        let a1p = (1.0 + G) * a1
        let a2p = (1.0 + G) * a2

        // Adjusted chroma
        let C1p = sqrt(a1p*a1p + b1*b1)
        let C2p = sqrt(a2p*a2p + b2*b2)
        let avgCp = (C1p + C2p) / 2.0

        // Adjusted hue angles (degrees)
        func atan2d(_ y: Double, _ x: Double) -> Double {
            var theta = atan2(y, x) * 180.0 / .pi
            if theta < 0 { theta += 360.0 }
            return theta
        }
        let h1p = C1p < 1e-7 ? 0.0 : atan2d(b1, a1p)
        let h2p = C2p < 1e-7 ? 0.0 : atan2d(b2, a2p)

        // Differences
        let deltaLp = L2 - L1
        let deltaCp = C2p - C1p

        // Δhp (degrees) → ΔHp (radians-based term)
        let dh: Double = {
            if C1p * C2p == 0 { return 0.0 }
            var d = h2p - h1p
            if d > 180 { d -= 360 }
            if d < -180 { d += 360 }
            return d
        }()
        let deltaHp = 2.0 * sqrt(C1p * C2p) * sin((dh * deg2rad) / 2.0)

        // Averages
        let avgLp = (L1 + L2) / 2.0
        let avgHp: Double = {
            if C1p * C2p == 0 { return h1p + h2p }
            var sum = h1p + h2p
            if abs(h1p - h2p) > 180 { sum += (sum < 360 ? 360 : -360) }
            return sum / 2.0
        }()

        // Weighting functions
        let T =
            1.0
            - 0.17 * cos((avgHp - 30.0) * deg2rad)
            + 0.24 * cos((2.0 * avgHp) * deg2rad)
            + 0.32 * cos((3.0 * avgHp + 6.0) * deg2rad)
            - 0.20 * cos((4.0 * avgHp - 63.0) * deg2rad)

        let deltaTheta = 30.0 * exp(-pow((avgHp - 275.0)/25.0, 2.0))
        let Rc = 2.0 * sqrt(pow(avgCp, 7.0) / (pow(avgCp, 7.0) + pow(25.0, 7.0)))
        let Sl = 1.0 + (0.015 * pow(avgLp - 50.0, 2.0)) / sqrt(20.0 + pow(avgLp - 50.0, 2.0))
        let Sc = 1.0 + 0.045 * avgCp
        let Sh = 1.0 + 0.015 * avgCp * T
        let Rt = -sin(2.0 * deltaTheta * deg2rad) * Rc

        // Final
        let termL = deltaLp / (kL * Sl)
        let termC = deltaCp / (kC * Sc)
        let termH = deltaHp / (kH * Sh)
        return sqrt(termL*termL + termC*termC + termH*termH + Rt * termC * termH)
    }
}
