//
//  RGBA.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

struct RGBA: Equatable {
    var r: Double; var g: Double; var b: Double; var a: Double
    
    static func fromHexString(_ s: String) -> RGBA? {
        var hex = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, let v = Int(hex, radix: 16) else { return nil }
        let r = Double((v >> 16) & 0xFF) / 255.0
        let g = Double((v >> 8) & 0xFF) / 255.0
        let b = Double(v & 0xFF) / 255.0
        return RGBA(r: r, g: g, b: b, a: 1)
    }
    
    static func fromRGBText(_ s: String) -> RGBA? {
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
    
    var hexString: String {
        let R = Int(round(r * 255)), G = Int(round(g * 255)), B = Int(round(b * 255))
        return String(format: "#%02X%02X%02X", R, G, B)
    }
    
    private func clamp01(_ x: Double) -> Double { min(max(0, x), 1) }
}
