//
//  DerivedPairResultView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI

struct DerivedPairResultView: View {
    let pair: DerivedPair
    let export: () -> String
    
    @State private var showSheet = false
    @State private var bias: Double = 0.0
    
    // Recompute twins from current bias
    private var recomputed: DerivedPair {
        DerivedPairEngine.derive(from: pair.target, bias: bias)
    }

    // Contrast bases
    private var white: RGBA { RGBA(r: 1, g: 1, b: 1, a: 1) }
    private var lightBG: RGBA { RGBA(r: 1, g: 1, b: 1, a: 1) }
    private var darkBG:  RGBA { RGBA(r: 0.12, g: 0.12, b: 0.12, a: 1) } // ~#1F1F1F

    // White text on color (AA for normal text = 4.5×)
    private var lightTextCR: Double { WCAG.contrastRatio(fg: white, bg: recomputed.light) }
    private var darkTextCR:  Double { WCAG.contrastRatio(fg: white, bg: recomputed.dark) }
    private var lightTextPass: Bool { WCAG.passesAA(normalText: lightTextCR) }
    private var darkTextPass:  Bool { WCAG.passesAA(normalText: darkTextCR) }

    // Color vs background (UI element legibility target ≈ 3:1)
    private var lightVsBGCR: Double { WCAG.contrastRatio(fg: recomputed.light, bg: lightBG) }
    private var darkVsBGCR:  Double { WCAG.contrastRatio(fg: recomputed.dark,  bg: darkBG) }
    private var lightVsBGPass: Bool { lightVsBGCR >= 3.0 }
    private var darkVsBGPass:  Bool { darkVsBGCR  >= 3.0 }

    // Quick formatters
    private func r(_ x: Double) -> String { String(format: "%.2fx", x) }

 /*
    // Recompute the twins whenever `bias` changes
    private var recomputed: DerivedPair {
        DerivedPairEngine.derive(from: pair.target, bias: bias)
    }

    private var white: RGBA { RGBA(r: 1, g: 1, b: 1, a: 1) }
*/
    private var lightCR: Double { WCAG.contrastRatio(fg: white, bg: recomputed.light) }
    private var darkCR:  Double { WCAG.contrastRatio(fg: white, bg: recomputed.dark) }

    private var bothPass: Bool {
        WCAG.passesAA(normalText: lightCR) && WCAG.passesAA(normalText: darkCR)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                Text(String(format: "Δ Light: %.2fx", lightCR)).monospaced()
                Text(String(format: "Δ Dark:  %.2fx", darkCR)).monospaced()
                Label(bothPass ? "WCAG: BOTH PASS" : "WCAG: FAIL",
                      systemImage: bothPass ? "checkmark.seal" : "xmark.seal")
                    .foregroundStyle(bothPass ? .green : .red)
                Spacer()
            }

            LabeledContent("Brightness Bias") {
                Slider(value: $bias, in: -0.12...0.12, step: 0.01)
                Text(String(format: "%+.2f", bias)).monospaced()
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    TwinPreview(title: "Light", rgba: recomputed.light)
                    HStack(spacing: 8) {
                        PassBadge(title: "Text \(r(lightTextCR))", pass: lightTextPass)
                        PassBadge(title: "BG \(r(lightVsBGCR))",   pass: lightVsBGPass)
                    }
                    .fontDesign(.monospaced)
                }

                VStack(alignment: .leading, spacing: 6) {
                    TwinPreview(title: "Dark", rgba: recomputed.dark)
                    HStack(spacing: 8) {
                        PassBadge(title: "Text \(r(darkTextCR))", pass: darkTextPass)
                        PassBadge(title: "BG \(r(darkVsBGCR))",   pass: darkVsBGPass)
                    }
                    .fontDesign(.monospaced)
                }
            }


            Button("Export to Assets + SwiftUI") { showSheet = true }
                .sheet(isPresented: $showSheet) {
                    ExportSheet(snippet: Exporter.derivedPairSnippet(name: "BrandPrimary",
                                                                     pair: recomputed))
                }
        }
    }

}

#Preview("Derived Pair") {
    DerivedPairResultView(
        pair: .sample,
        export: { Exporter.derivedPairSnippet(name: "BrandPrimary", pair: .sample) }
    )
    .frame(width: 860)
    .padding(20)
}
