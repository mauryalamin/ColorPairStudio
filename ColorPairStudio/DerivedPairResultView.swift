//
//  DerivedPairResultView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI

struct DerivedPairResultView: View {
    // Stored props
    let pair: DerivedPair
    let onExport: (String) -> Void

    // Single source of truth: bias comes in as a Binding
    @Binding private var bias: Double

    // ✅ Preferred initializer
    init(pair: DerivedPair,
         bias: Binding<Double>,
         onExport: @escaping (String) -> Void = { _ in }) {
        self.pair = pair
        self.onExport = onExport
        self._bias = bias
    }
    
    // Recompute twins from current bias
    private var recomputed: DerivedPair {
        DerivedPairEngine.derive(from: pair.target, bias: bias)
    }
    
    private var snippet: String {
        Exporter.derivedPairSnippet(name: "BrandPrimary", pair: recomputed)
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

    private var lightCR: Double { WCAG.contrastRatio(fg: white, bg: recomputed.light) }
    private var darkCR:  Double { WCAG.contrastRatio(fg: white, bg: recomputed.dark) }
    
    private var lightPass: Bool { WCAG.passesAA(normalText: lightTextCR) }
    private var darkPass: Bool  { WCAG.passesAA(normalText: darkTextCR) }
    
    private var bothPass: Bool {
        WCAG.passesAA(normalText: lightCR) && WCAG.passesAA(normalText: darkCR)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            HStack(spacing: 12) {
                Text(String(format: "Δ Light: %.2fx", lightCR)).monospaced()
                Text(String(format: "Δ Dark:  %.2fx", darkCR)).monospaced()
                Label(bothPass ? "Both PASS" : "Both FAIL",
                      systemImage: bothPass ? "checkmark.seal" : "xmark.seal")
                .accessibilityLabel(bothPass ? "Both twins pass contrast" : "Both twins fail contrast")
                .foregroundStyle(bothPass ? .green : .red)
                
                Spacer()
                
                Button("Export to Assets + SwiftUI") {
                    onExport(snippet)
                }
                    .keyboardShortcut("e", modifiers: [.command])
                    .accessibilityLabel("Export to Assets and SwiftUI")
                    .accessibilityHint("Opens a window with steps and code for Xcode")
            }
            
            LabeledContent("Brightness Bias") {
                Slider(value: $bias, in: -0.25...0.25)
                Text(String(format: "%+.2f", bias)).monospaced()
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    TwinPreview(title: "Light", rgba: recomputed.light)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Light twin")
                        .accessibilityValue(
                                "\(recomputed.light.hexString) " +
                                String(format: "white text %.2fx %@", lightTextCR, lightPass ? "passes" : "fails")
                            )
                    HStack(spacing: 8) {
                        PassBadge(title: "Text \(r(lightTextCR))", pass: lightTextPass)
                        PassBadge(title: "BG \(r(lightVsBGCR))",   pass: lightVsBGPass)
                    }
                    .fontDesign(.monospaced)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    TwinPreview(title: "Dark", rgba: recomputed.dark)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Dark twin")
                        .accessibilityValue(
                                "\(recomputed.dark.hexString) " +
                                String(format: "white text %.2fx %@", darkTextCR, darkPass ? "passes" : "fails")
                            )
                    HStack(spacing: 8) {
                        PassBadge(title: "Text \(r(darkTextCR))", pass: darkTextPass)
                        PassBadge(title: "BG \(r(darkVsBGCR))",   pass: darkVsBGPass)
                    }
                    .fontDesign(.monospaced)
                }
            }
            
            
            
        }
        .focusedSceneValue(\.exportAction) {
            onExport(snippet)
        }
    }
    
}

// MARK: - Back-compat wrapper for your old init(pair:onExport:)
extension DerivedPairResultView {
    @available(*, deprecated, message: "Prefer init(pair:bias:onExport:) with a Binding (e.g., bias: $vm.bias).")
    static func legacy(pair: DerivedPair,
                       onExport: @escaping (String) -> Void = { _ in }) -> some View {
        _DerivedPairResultViewWithState(pair: pair, onExport: onExport)
    }
}

// A tiny wrapper view that owns a local @State and passes it as a Binding
private struct _DerivedPairResultViewWithState: View {
    let pair: DerivedPair
    let onExport: (String) -> Void
    @State private var localBias: Double = 0.0

    var body: some View {
        DerivedPairResultView(pair: pair, bias: $localBias, onExport: onExport)
    }
}

extension DerivedPair {
    static func sampleComputed() -> DerivedPair {
        let target = RGBA(r: 0.3, g: 0.5, b: 0.7, a: 1)
        let pair   = DerivedPairEngine.derive(from: target, bias: 0)
        let white  = RGBA(r: 1, g: 1, b: 1, a: 1)

        let lightCR = WCAG.contrastRatio(fg: white, bg: pair.light)
        let darkCR  = WCAG.contrastRatio(fg: white, bg: pair.dark)
        let pass    = (lightCR >= 4.5) && (darkCR >= 4.5)   // AA body text threshold

        return DerivedPair(target: target, light: pair.light, dark: pair.dark, wcagPass: pass)
    }
}

#Preview("Derived Pair") {
    DerivedPairResultView(pair: .sample, bias: .constant(0.0))
        .frame(width: 860)
        .padding(20)
}
