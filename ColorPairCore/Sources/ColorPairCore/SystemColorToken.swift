//
//  SystemColorToken.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/19/25.
//

import Foundation

public enum SystemColorToken: String, CaseIterable, Codable, Sendable {
    case red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown, gray
    case primary, secondary
    case black, white, clear
    
    /// Swift source expression you can drop into code
    var swiftExpr: String { "Color.\(rawValue)" }
    
    public var displayName: String {
        switch self {
        case .primary:   return "Primary"
        case .secondary: return "Secondary"
        case .clear:     return "Clear"
        default:         return rawValue.capitalized   // e.g., "Indigo"
        }
    }
 
    
    /// sRGB approximations suitable for ΔE/contrast math in Approximator
    var rgbaApprox: RGBA {
        switch self {
        case .red:     return RGBA(r: 1.00, g: 0.23, b: 0.19, a: 1.0)   // 255,59,48
        case .orange:  return RGBA(r: 1.00, g: 0.59, b: 0.00, a: 1.0)   // 255,149,0
        case .yellow:  return RGBA(r: 1.00, g: 0.84, b: 0.04, a: 1.0)   // 255,214,10
        case .green:   return RGBA(r: 0.20, g: 0.78, b: 0.35, a: 1.0)   // 52,199,89
        case .mint:    return RGBA(r: 0.00, g: 0.78, b: 0.75, a: 1.0)   // ~0,199,190
        case .teal:    return RGBA(r: 0.19, g: 0.69, b: 0.78, a: 1.0)   // 48,176,199
        case .cyan:    return RGBA(r: 0.20, g: 0.68, b: 0.90, a: 1.0)   // 50,173,230
        case .blue:    return RGBA(r: 0.00, g: 0.48, b: 1.00, a: 1.0)   // 0,122,255
        case .indigo:  return RGBA(r: 0.35, g: 0.34, b: 0.84, a: 1.0)   // 88,86,214
        case .purple:  return RGBA(r: 0.69, g: 0.32, b: 0.87, a: 1.0)   // 175,82,222
        case .pink:    return RGBA(r: 1.00, g: 0.18, b: 0.33, a: 1.0)   // 255,45,85
        case .brown:   return RGBA(r: 0.64, g: 0.52, b: 0.37, a: 1.0)   // 162,132,94
        case .gray:    return RGBA(r: 0.56, g: 0.56, b: 0.58, a: 1.0)   // 142,142,147
        case .black:   return RGBA(r: 0.00, g: 0.00, b: 0.00, a: 1.0)
        case .white:   return RGBA(r: 1.00, g: 1.00, b: 1.00, a: 1.0)
        case .clear:   return RGBA(r: 0.00, g: 0.00, b: 0.00, a: 0.0)
        case .primary:   return RGBA(r: 0.00, g: 0.00, b: 0.00, a: 1.0) // stand-in for math
        case .secondary: return RGBA(r: 0.56, g: 0.56, b: 0.58, a: 1.0) // stand-in
        }
    }
    
    /// Accepts ".red", "red", or "Color.red" and normalizes to a token.
    init?(normalizing s: String) {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("Color.") { self.init(rawValue: String(t.dropFirst("Color.".count))) }
        else if t.hasPrefix(".") { self.init(rawValue: String(t.dropFirst())) }
        else { self.init(rawValue: t) }
    }
}
