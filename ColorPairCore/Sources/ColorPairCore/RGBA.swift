//
//  RGBA.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

public struct HSB { var h: Double; var s: Double; var b: Double } // h in [0,360)

public struct RGBA: Equatable {
    public var r: Double
    public var g: Double
    public var b: Double
    public var a: Double
    
    // Explicit public initializer so app code can do RGBA(r:g:b:a:)
    public init(r: Double, g: Double, b: Double, a: Double) {
        self.r = r; self.g = g; self.b = b; self.a = a
    }
    
    // Nice-to-have shortcuts
    public static let white = RGBA(r: 1, g: 1, b: 1, a: 1)
    public static let black = RGBA(r: 0, g: 0, b: 0, a: 1)
    
    public static func fromHexString(_ s: String) -> RGBA? {
        var hex = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, let v = Int(hex, radix: 16) else { return nil }
        let r = Double((v >> 16) & 0xFF) / 255.0
        let g = Double((v >> 8) & 0xFF) / 255.0
        let b = Double(v & 0xFF) / 255.0
        return RGBA(r: r, g: g, b: b, a: 1)
    }
    
    public static func fromRGBText(_ s: String) -> RGBA? {
        let parts = s.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 3,
              let r = Double(parts[0]), let g = Double(parts[1]), let b = Double(parts[2])
        else { return nil }
        return RGBA(r: r/255.0, g: g/255.0, b: b/255.0, a: 1)
    }
    
    func rgbDistance(to other: RGBA) -> Double {
        let dr = r - other.r, dg = g - other.g, db = b - other.b
        return sqrt(dr*dr + dg*dg + db*db)
    }
    
    func adjust(brightness delta: Double) -> RGBA {
        RGBA(r: clamp01(r + delta), g: clamp01(g + delta), b: clamp01(b + delta), a: a)
    }
    
    public var hexString: String {
        let R = Int(round(r * 255)), G = Int(round(g * 255)), B = Int(round(b * 255))
        return String(format: "#%02X%02X%02X", R, G, B)
    }
    
    private func clamp01(_ x: Double) -> Double { min(max(0, x), 1) }
}

extension RGBA: Codable, Sendable {
    
    public var asRGBText: String { "\(Int(r*255)),\(Int(g*255)),\(Int(b*255))" }
    
    func toHSB() -> HSB {
        let r = r, g = g, b = b
        let maxv = max(r, g, b), minv = min(r, g, b)
        let delta = maxv - minv
        // Hue
        var h: Double
        if delta == 0 { h = 0 }
        else if maxv == r { h = 60 * fmod(((g - b) / delta), 6) }
        else if maxv == g { h = 60 * (((b - r) / delta) + 2) }
        else { h = 60 * (((r - g) / delta) + 4) }
        if h < 0 { h += 360 }
        // Saturation
        let s = maxv == 0 ? 0 : (delta / maxv)
        // Brightness
        let v = maxv
        return HSB(h: h, s: s, b: v)
    }
    
    static func fromHSB(_ hsb: HSB, alpha: Double = 1) -> RGBA {
        let c = hsb.b * hsb.s
        let x = c * (1 - abs(fmod(hsb.h / 60.0, 2) - 1))
        let m = hsb.b - c
        let (rp, gp, bp): (Double, Double, Double)
        switch hsb.h {
        case 0..<60:   (rp, gp, bp) = (c, x, 0)
        case 60..<120: (rp, gp, bp) = (x, c, 0)
        case 120..<180:(rp, gp, bp) = (0, c, x)
        case 180..<240:(rp, gp, bp) = (0, x, c)
        case 240..<300:(rp, gp, bp) = (x, 0, c)
        default:       (rp, gp, bp) = (c, 0, x)
        }
        return RGBA(r: rp + m, g: gp + m, b: bp + m, a: alpha)
    }
    
    /// Apply the same adjustments you show in UI (degrees, sat multiplier, brightness delta)
    public func applying(hueDegrees: Double, satMultiplier: Double, brightnessDelta: Double) -> RGBA {
        var hsb = toHSB()
        hsb.h = fmod((hsb.h + hueDegrees + 360), 360)
        hsb.s = min(max(hsb.s * satMultiplier, 0), 1)
        hsb.b = min(max(hsb.b + brightnessDelta, 0), 1)
        return RGBA.fromHSB(hsb, alpha: a)
    }
}
