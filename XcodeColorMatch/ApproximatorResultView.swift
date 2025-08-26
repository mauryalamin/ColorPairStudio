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

    // NEW: local slider state
    @State private var hue: Double
    @State private var sat: Double
    @State private var bri: Double

    init(output: ApproximatedOutput, export: @escaping () -> String) {
        self.output = output
        self.export = export
        _hue = State(initialValue: output.hueDegrees)
        _sat = State(initialValue: output.saturation)
        _bri = State(initialValue: output.brightness)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Target \(output.target.hexString)")
                Text("Base: \(output.baseName)")
                Text("Δ ~ \(String(format: "%.2f", output.deltaE))")
                Label("WCAG: PASS", systemImage: "checkmark.seal") // stub
                    .foregroundStyle(.green)
                Spacer()
                Button("Export Snippet") { showSheet = true }
            }

            // NEW: sliders
            VStack(alignment: .leading) {
                LabeledContent("Hue Rotation") {
                    Slider(value: $hue, in: -15...15, step: 1) { Text("") }
                    Text("\(Int(hue))°").monospaced()
                }
                LabeledContent("Saturation") {
                    Slider(value: $sat, in: 0.85...1.10, step: 0.01) { Text("") }
                    Text(String(format: "%.2f", sat)).monospaced()
                }
                LabeledContent("Brightness") {
                    Slider(value: $bri, in: -0.08...0.08, step: 0.01) { Text("") }
                    Text(String(format: "%.2f", bri)).monospaced()
                }
            }

            PreviewRow(fill: output.baseColor, hue: hue, sat: sat, bri: bri)
        }
        .sheet(isPresented: $showSheet) {
            // export using the current slider values
            let updated = ApproximatedOutput(
                target: output.target,
                baseName: output.baseName,
                baseColor: output.baseColor,
                hueDegrees: hue, saturation: sat, brightness: bri,
                deltaE: output.deltaE, wcagPass: output.wcagPass
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
