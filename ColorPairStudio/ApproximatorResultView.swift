//
//  ApproximatorResultView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI

struct ApproximatorResultView: View {
    let output: ApproximatedOutput
    let onExport: (String) -> Void   // parent-provided presenter

    // Live slider state
    @State private var hue: Double
    @State private var sat: Double
    @State private var bri: Double

    // Range toggle
    @State private var moreRange = false
    private var hueRange: ClosedRange<Double> { moreRange ? -180...180   : -15...15 }
    private var satRange: ClosedRange<Double> { moreRange ?   0.00...2.00 :  0.85...1.10 }
    private var briRange: ClosedRange<Double> { moreRange ?  -1.00...1.00 : -0.08...0.08 }

    init(output: ApproximatedOutput, onExport: @escaping (String) -> Void = { _ in }) {
        self.output = output
        self.onExport = onExport
        _hue = State(initialValue: output.hueDegrees)
        _sat = State(initialValue: output.saturation)
        _bri = State(initialValue: output.brightness)
    }

    // MARK: - Live metrics based on sliders

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

    // White text contrast vs adjusted fill
    private var liveContrast: Double {
        WCAG.contrastRatio(fg: RGBA(r: 1, g: 1, b: 1, a: 1), bg: adjustedRGBA)
    }
    private var wcagPass: Bool { WCAG.passesAA(normalText: liveContrast) }

    // Nudge brightness darker until AA passes (or bounds)
    private func fixContrast() {
        var trial = bri
        let step   = moreRange ? 0.02 : 0.01
        let minBri = moreRange ? -1.0 : -0.08

        var passes = wcagPass
        var guardrail = 0
        while !passes && guardrail < 80 {
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

    // MARK: - Export snippet built from *live* values

    private var snippet: String {
        // Format nicely; omit no-op modifiers
        let base = output.baseName
        let hueDeg = Int(hue.rounded())
        let satStr = String(format: "%.2f", sat)
        let briStr = String(format: "%.2f", bri)

        var lines: [String] = ["Color.\(base)"]
        if hueDeg != 0       { lines.append("    .hueRotation(.degrees(\(hueDeg)))") }
        if abs(sat - 1.0) > 0.0001 { lines.append("    .saturation(\(satStr))") }
        if abs(bri) > 0.0001 { lines.append("    .brightness(\(briStr))") }

        return lines.joined(separator: "\n")
    }

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header metrics + actions
            HStack(spacing: 12) {
                Text("Target \(output.target.hexString)")
                Text("Base: \(output.baseName)")
                Text(String(format: "ΔE00 %.2f (%@)", liveDeltaE, deltaLabel))
                    .monospaced()

                Label(
                    String(format: "WCAG: %.2fx %@", liveContrast, wcagPass ? "PASS" : "FAIL"),
                    systemImage: wcagPass ? "checkmark.seal" : "xmark.seal"
                )
                .foregroundStyle(wcagPass ? .green : .red)

                if !wcagPass {
                    Button("Fix Contrast") { fixContrast() }
                        .buttonStyle(.bordered)
                        .help("Nudge brightness until AA passes")
                }

                Spacer()

                Button("Export Snippet…") {
                    onExport(snippet)
                }
                .keyboardShortcut("e", modifiers: [.command])
            }

            // Range toggle
            Toggle("More range (may look less ‘native’)", isOn: $moreRange)
                .onChange(of: moreRange) { oldValue, newValue in
                    if oldValue == true && newValue == false {
                        // Clamp to default subranges when turning off
                        hue = min(max(hue, hueRange.lowerBound), hueRange.upperBound)
                        sat = min(max(sat, satRange.lowerBound), satRange.upperBound)
                        bri = min(max(bri, briRange.lowerBound), briRange.upperBound)
                    }
                }

            // Sliders
            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Hue Rotation") {
                    if moreRange {
                        Slider(value: $hue, in: -180...180)
                    } else {
                        Slider(value: $hue, in: -15...15, step: 1)
                    }
                    Text("\(Int(hue))°").monospaced()
                }

                LabeledContent("Saturation") {
                    if moreRange {
                        Slider(value: $sat, in: 0.00...2.00)
                    } else {
                        Slider(value: $sat, in: 0.85...1.10, step: 0.01)
                    }
                    Text(String(format: "%.2f", sat)).monospaced()
                }

                LabeledContent("Brightness") {
                    if moreRange {
                        Slider(value: $bri, in: -1.00...1.00)
                    } else {
                        Slider(value: $bri, in: -0.08...0.08, step: 0.01)
                    }
                    Text(String(format: "%.2f", bri)).monospaced()
                }
            }

            // Visual preview uses the same pipeline as export snippet
            PreviewRow(fill: output.baseColor, hue: hue, sat: sat, bri: bri)
        }
        // Make global ⌘E call the same path as the button
        .focusedSceneValue(\.exportAction) { onExport(snippet) }
    }
}

#Preview("Approximator — PASS") {
    ApproximatorResultView(
        output: .samplePass    // make sure you’ve defined this fixture elsewhere
    )
    .frame(width: 860)
    .padding(20)
}

#Preview("Approximator — FAIL") {
    ApproximatorResultView(
        output: .sampleFail
    )
    .frame(width: 860)
    .padding(20)
}
