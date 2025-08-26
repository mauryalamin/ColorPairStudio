//
//  Exporter.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

enum Exporter {
    static func approximatorSnippet(output: ApproximatedOutput) -> String {
        """
        // Target: \(output.target.hexString) Delta: \(String(format: "%.2f", output.deltaE)) WCAG: \(output.wcagPass ? "PASS" : "FAIL")
        struct BrandFilledCapsule: View {
            var title: String
            var body: some View {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 8).padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(\(output.baseName))
                            .hueRotation(.degrees(\(Int(output.hueDegrees))))
                            .saturation(\(String(format: "%.2f", output.saturation)))
                            .brightness(\(String(format: "%.2f", output.brightness)))
                    )
            }
        }
        """
    }
    
    static func derivedPairSnippet(name: String, pair: DerivedPair) -> String {
        """
        // Add a Color Set named \(name) with Light/Dark values.
        extension Color { static let \(camelCase(name)) = Color("\(name)") }
        // Light: \(pair.light.hexString) Dark: \(pair.dark.hexString)
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
