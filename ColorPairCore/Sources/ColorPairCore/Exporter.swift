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

public enum Exporter {
    public static func approximatorSnippet(output: ApproximatedOutput) -> String {
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
    
    public static func derivedPairSnippet(name: String, pair: DerivedPair) -> String {
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
        // 1) Remove non-alphanumerics -> spaces
        let cleaned = s.replacingOccurrences(of: #"[^A-Za-z0-9]+"#,
                                             with: " ",
                                             options: .regularExpression)

        // 2) Split each token on case boundaries: "BrandPrimary" -> ["Brand","Primary"]
        let pattern = #"([A-Z]+(?![a-z])|[A-Z]?[a-z]+|[0-9]+)"#
        let regex = try! NSRegularExpression(pattern: pattern)

        var words: [String] = []
        for raw in cleaned.split(separator: " ") {
            let str = String(raw)
            let ns = str as NSString
            let matches = regex.matches(in: str, range: NSRange(location: 0, length: ns.length))
            words += matches.map { ns.substring(with: $0.range) }
        }

        guard let first = words.first else { return s.lowercased() }
        let head = first.lowercased()
        let tail = words.dropFirst().map { $0.capitalized }.joined()
        return head + tail
    }
}
