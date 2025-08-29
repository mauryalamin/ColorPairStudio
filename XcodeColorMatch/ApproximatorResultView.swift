//
//  ApproximatorResultView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI

struct ApproximatorResultView: View {
    let output: ApproximatedOutput
    let export: () -> String
    @State private var showSheet = false
    
    // live slider state
    @State private var hue: Double
    @State private var sat: Double
    @State private var bri: Double
    
    // NEW: widen ranges on demand
    @State private var moreRange = false
    private var hueRange: ClosedRange<Double> { moreRange ? -180...180   : -15...15 }
    private var satRange: ClosedRange<Double> { moreRange ?  0.00...2.00 :  0.85...1.10 }
    private var briRange: ClosedRange<Double> { moreRange ? -1.00...1.00 : -0.08...0.08 }
    
    init(output: ApproximatedOutput, export: @escaping () -> String) {
        self.output = output
        self.export = export
        _hue = State(initialValue: output.hueDegrees)
        _sat = State(initialValue: output.saturation)
        _bri = State(initialValue: output.brightness)
    }
    
    
    // Derived metrics for the header / export
    // Inside ApproximatorResultView, add these computed props above `var body`
    private var adjustedRGBA: RGBA {
        output.baseRGBA.applying(
            hueDegrees: hue,
            satMultiplier: sat,
            brightnessDelta: bri
        )
    }

    private var liveDeltaE: Double {
        DeltaE.ciede2000(output.target.toLab(), adjustedRGBA.toLab())
    }

    private var deltaLabel: String {
        switch liveDeltaE {
        case ..<1.0: return "Very Low"
        case ..<2.0: return "Low"
        case ..<5.0: return "Medium"
        default:     return "High"
        }
    }

    // Real WCAG (white text on the adjusted fill)
    private var liveContrast: Double {
        WCAG.contrastRatio(fg: RGBA(r: 1, g: 1, b: 1, a: 1), bg: adjustedRGBA)
    }
    private var wcagPass: Bool { WCAG.passesAA(normalText: liveContrast) }
    
    private func fixContrast() {
        // Try darkening background (better for white text) until AA passes or we hit bounds
        var trial = bri
        let step = moreRange ? 0.02 : 0.01
        let minBri = moreRange ? -1.0 : -0.08

        var passes = wcagPass
        var guardrail = 0
        while !passes && guardrail < 80 {
            // Darken a bit
            trial = max(trial - step, minBri)
            let testBG = output.baseRGBA.applying(
                hueDegrees: hue, satMultiplier: sat, brightnessDelta: trial
            )
            let ratio = WCAG.contrastRatio(fg: RGBA(r: 1, g: 1, b: 1, a: 1), bg: testBG)
            passes = WCAG.passesAA(normalText: ratio)
            guardrail += 1
            if trial == minBri { break }
        }
        withAnimation { bri = trial }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 2) In your header HStack inside var body, add the button after the WCAG badge:

            HStack {
                Text("Target \(output.target.hexString)")
                Text("Base: \(output.baseName)")
                Text(String(format: "ΔE00 %.2f (%@)", liveDeltaE, deltaLabel)).monospaced()

                Label(String(format: "WCAG: %.2fx %@", liveContrast, wcagPass ? "PASS" : "FAIL"),
                      systemImage: wcagPass ? "checkmark.seal" : "xmark.seal")
                    .foregroundStyle(wcagPass ? .green : .red)

                // Show only when failing
                if !wcagPass {
                    Button("Fix Contrast") { fixContrast() }
                        .buttonStyle(.bordered)                // or .borderedProminent for emphasis
                        .help("Automatically nudge brightness until AA passes")
                }

                Spacer()

                Button("Export Snippet") { showSheet = true }
                    .keyboardShortcut("e", modifiers: [.command])
            }

            
            // NEW: More range toggle (lets users stretch farther if needed)
            Toggle("More range (may look less 'native')", isOn: $moreRange)
                .onChange(of: moreRange) { oldValue, newValue in
                    if oldValue == true && newValue == false {
                        // we just narrowed the ranges → clamp current values
                        hue = min(max(hue, -15), 15)
                        sat = min(max(sat, 0.85), 1.10)
                        bri = min(max(bri, -0.08), 0.08)
                    }
                }
            
            // Guard-ranged sliders that respect the toggle
            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Hue Rotation") {
                    if moreRange {
                        Slider(value: $hue, in: -180...180) // continuous
                    } else {
                        Slider(value: $hue, in: -15...15, step: 1) // discrete, tidy ticks
                    }
                    Text("\(Int(hue))°").monospaced()
                }
                
                LabeledContent("Saturation") {
                    if moreRange {
                        Slider(value: $sat, in: 0.00...2.00)      // continuous
                    } else {
                        Slider(value: $sat, in: 0.85...1.10, step: 0.01)
                    }
                    Text(String(format: "%.2f", sat)).monospaced()
                }
                
                LabeledContent("Brightness") {
                    if moreRange {
                        Slider(value: $bri, in: -1.00...1.00)     // continuous
                    } else {
                        Slider(value: $bri, in: -0.08...0.08, step: 0.01)
                    }
                    Text(String(format: "%.2f", bri)).monospaced()
                }
            }
            
            // Previews use the visual pipeline (shape-first; modifiers after .fill)
            PreviewRow(fill: output.baseColor, hue: hue, sat: sat, bri: bri)
        }
        .sheet(isPresented: $showSheet) {
            let updated = ApproximatedOutput(
                target: output.target,
                baseName: output.baseName,
                baseColor: output.baseColor,
                baseRGBA: output.baseRGBA,
                hueDegrees: hue, saturation: sat, brightness: bri,
                deltaE: liveDeltaE, wcagPass: wcagPass
            )
            ExportSheet(snippet: Exporter.approximatorSnippet(output: updated))
        }
    }
}



#Preview("Approximator — PASS") {
    ApproximatorResultView(
        output: .samplePass,
        export: { Exporter.approximatorSnippet(output: .samplePass) }
    )
    .frame(width: 860)
    .padding(20)
}

#Preview("Approximator — FAIL") {
    ApproximatorResultView(
        output: .sampleFail,
        export: { Exporter.approximatorSnippet(output: .sampleFail) }
    )
    .frame(width: 860)
    .padding(20)
}
