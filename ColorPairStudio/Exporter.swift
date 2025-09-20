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
    static func approximatorSnippet(output out: ApproximatedOutput) -> String {
        // Normalize the base name to "Color.<dotless>"
        let fillColor: String = {
            // Try the structured token first (handles ".red" or "red")
            if let token = SystemColorToken(maybeDotted: out.baseName.withoutColorPrefix) {
                return "Color.\(token.swiftName)"
            }
            // Fallback: strip any "Color." and leading dot
            let clean = out.baseName
                .withoutColorPrefix      // "Color.red" -> "red"
                .withoutLeadingDot       // ".red" -> "red"
            return "Color.\(clean)"
        }()

        return """
        // Target: \(out.target.hexString)  ΔE00: \(String(format: "%.2f", out.deltaE))  WCAG: \(out.wcagPass ? "PASS" : "FAIL")
        struct BrandFilledCapsule: View {
            var title: String
            var body: some View {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 8).padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(\(fillColor))
                            .hueRotation(.degrees(\(Int(out.hueDegrees))))
                            .saturation(\(String(format: "%.2f", out.saturation)))
                            .brightness(\(String(format: "%.2f", out.brightness)))
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
