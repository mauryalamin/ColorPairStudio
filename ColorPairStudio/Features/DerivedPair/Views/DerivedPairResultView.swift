//
//  DerivedPairResultView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import AppKit
import SwiftUI
import ColorPairCore

struct DerivedPairResultView: View {
    // Stored props
    let pair: DerivedPair
    let onExport: (String) -> Void
    
    // Bindings
    @Binding private var bias: Double
    @Binding private var keepLightExact: Bool   // ← NEW
    
    @State private var copiedLight = false
    @State private var copiedDark  = false
    
    // Init including the new toggle
    init(pair: DerivedPair,
         bias: Binding<Double>,
         keepLightExact: Binding<Bool>,
         onExport: @escaping (String) -> Void = { _ in }) {
        self.pair = pair
        self.onExport = onExport
        self._bias = bias
        self._keepLightExact = keepLightExact
    }
    
    // Recompute twins using the policy derived from the toggle
    private var recomputed: DerivedPair {
        let policy: PairPolicy = keepLightExact ? .exactLightIfCompliant : .guardrailed
        return DerivedPairEngine.derive(from: pair.target, bias: bias, policy: policy)
    }
    
    private var snippet: String {
        Exporter.derivedPairSnippet(name: "BrandPrimary", pair: recomputed)
    }
    
    private var m: DerivedPairEngine.PairMetrics {
        DerivedPairEngine.metrics(for: recomputed)
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
    
    private func copyLight() {
        let hex = recomputed.light.hexString
        Clipboard.copy(hex)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) { copiedLight = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.25)) { copiedLight = false }
        }
        Analytics.track("copy_hex", ["feature": "DerivedPair", "twin": "light", "hex": hex])
    }

    private func copyDark() {
        let hex = recomputed.dark.hexString
        Clipboard.copy(hex)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) { copiedDark = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.25)) { copiedDark = false }
        }
        Analytics.track("copy_hex", ["feature": "DerivedPair", "twin": "dark", "hex": hex])
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            HStack(spacing: 12) {
                Text(String(format: "Text (AA) — Light: %.2fx   Dark: %.2fx", m.light.text, m.dark.text))
                    .monospaced()
                
                Label(m.overallSummary,
                      systemImage: m.overallPass ? "checkmark.seal" : "xmark.seal")
                .accessibilityLabel(m.overallPass ? "Both twins pass contrast" : "Both twins fail contrast")
                .foregroundStyle(m.overallPass ? .green : .red)
                
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
            
            Toggle(isOn: $keepLightExact) {
                Text("Keep Light exactly brand (when safe)")
            }
            .help("If the brand hex already passes on the Light background, keep Light exact and only adjust Dark to meet guardrails.")
            .accessibilityLabel("Keep Light exactly brand when safe")
            .accessibilityHint("When on, Light stays equal to the input color if it already meets contrast. Dark adjusts to remain readable.")
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    ZStack {
                        TwinPreview(title: "Light", rgba: recomputed.light, onTap: copyLight)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Light twin")
                            .accessibilityValue(
                                "\(recomputed.light.hexString) " +
                                String(format: "white text %.2fx %@", lightTextCR, lightPass ? "passes" : "fails")
                            )
                        if copiedLight { CopiedPill().padding(8) }
                    }
                    .contextMenu {
                        Button("Copy HEX \(recomputed.light.hexString)") { copyLight() }
                    }
                    HStack(spacing: 8) {
                        PassBadge(title: "Text \(r(m.light.text))", pass: m.light.text >= 4.5)
                        PassBadge(title: "BG \(r(m.light.bg))",     pass: m.light.bg   >= 3.0)
                    }
                    .fontDesign(.monospaced)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    ZStack {
                        TwinPreview(title: "Dark", rgba: recomputed.dark, onTap: copyDark)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Dark twin")
                            .accessibilityValue(
                                "\(recomputed.dark.hexString) " +
                                String(format: "white text %.2fx %@", darkTextCR, darkPass ? "passes" : "fails")
                            )
                        if copiedDark { CopiedPill().padding(8) }
                    }
                    .contextMenu {
                        Button("Copy HEX \(recomputed.light.hexString)") { copyLight() }
                    }
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
    @available(*, deprecated, message: "Prefer init(pair:bias:keepLightExact:onExport:).")
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
    @State private var localKeepLightExact = true
    
    var body: some View {
        DerivedPairResultView(
            pair: pair,
            bias: $localBias,
            keepLightExact: $localKeepLightExact,
            onExport: onExport
        )
    }
}

private struct CopiedPill: View {
    var body: some View {
        Label("Copied", systemImage: "doc.on.doc.fill")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(.thinMaterial, in: Capsule())
            .shadow(radius: 2, y: 1)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}


#Preview("Derived Pair") {
    DerivedPairResultView(
        pair: .sample,
        bias: .constant(0.0),
        keepLightExact: .constant(true)
    )
    .frame(width: 860)
    .padding(20)
}
