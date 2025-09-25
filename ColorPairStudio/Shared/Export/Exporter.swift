//
//  Exporter.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

// Add this tiny helper at file scope (top or bottom of Exporter.swift)
private extension String {
    var withoutLeadingDot: String {
        hasPrefix(".") ? String(dropFirst()) : self
    }
    var withoutColorPrefix: String {
        hasPrefix("Color.") ? String(dropFirst(6)) : self
    }
}

enum Exporter {
    static func approximatorSnippet(output: ApproximatedOutput) -> String {
        let base = output.swiftBaseExpr                // "Color.red"
        let h = output.hueDegrees
        let s = output.saturation
        let b = output.brightness
        
        // Build modifiers only when they’re not identity
        var mods: [String] = []
        if abs(h) > 0.0001 { mods.append(".hueRotation(.degrees(\(Int(h.rounded()))))") }
        if abs(s - 1.0) > 0.0001 { mods.append(String(format: ".saturation(%.2f)", s)) }
        if abs(b) > 0.0001 { mods.append(String(format: ".brightness(%.2f)", b)) }
        let modifierBlock = mods.joined(separator: "\n                            ")
        
        let header = String(
            format: "// Target: %@  ΔE: %.2f  WCAG: %@",
            output.target.hexString,
            output.deltaE,
            output.wcagPass ? "PASS" : "FAIL"
        )
        
        return """
            \(header)
            struct BrandFilledCapsule: View {
                var title: String
                var body: some View {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.vertical, 8).padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(\(base))\(modifierBlock.isEmpty ? "" : "\n                            \(modifierBlock)")
                        )
                }
            }
            """
    }
    
    static func derivedPairSnippet(name: String, pair: DerivedPair) -> String {
        """
        // Add a Color Set named \(name) with Light/Dark values.
        extension Color { static let \(camelCase(name)) = Color("\(name)") }
        // Light: \(pair.light.hexString)  Dark: \(pair.dark.hexString)
        // Usage:
        Button("Continue") { }
            .padding(.vertical, 8).padding(.horizontal, 16)
            .background(Color.\(camelCase(name)), in: .capsule)
            .foregroundStyle(.white)
        """
    }
    
    private static func camelCase(_ s: String) -> String {
        let parts = s.split(separator: " ")
        guard let first = parts.first else { return s }
        let head = first.lowercased()
        let tail = parts.dropFirst().map { $0.capitalized }.joined()
        return head + tail
    }
}
