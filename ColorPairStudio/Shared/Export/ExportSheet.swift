//
//  ExportSheet.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

// ExportSheet.swift
import SwiftUI
import AppKit

struct ExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    let snippet: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Export Preview").font(.headline)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Close")
                }
                .buttonStyle(.plain)
            }

            // Content
            ScrollView {
                Text(snippet)
                    .textSelection(.enabled)
                    .font(.system(.footnote, design: .monospaced))
                    .padding()
                    .accessibilityLabel("SwiftUI export code")
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .frame(minWidth: 640, minHeight: 320)

            // Footer (Copy + Close)
            HStack {
                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(snippet, forType: .string)
                }
                .accessibilityLabel("Copy code to clipboard")
                Spacer()
                Button("Close") { dismiss() }
            }
        }
        .padding(20)
    }
}

// Uses the Approximator sample
#Preview("ExportSheet — Approximator") {
    ExportSheet(snippet: Exporter.approximatorSnippet(output: .samplePass))
        .frame(width: 720, height: 400)
}

// Uses the Derived Pair sample
#Preview("ExportSheet — Derived Pair") {
    ExportSheet(snippet: Exporter.derivedPairSnippet(name: "BrandPrimary",
                                                     pair: DerivedPair.sample))
        .frame(width: 720, height: 400)
}

// Fallback: simple long string (if you haven’t added the sample extensions)
#Preview("ExportSheet — Long Text Fallback") {
    let long = (0..<40).map { "Line \($0): Lorem ipsum dolor sit amet…" }
                       .joined(separator: "\n")
    return ExportSheet(snippet: long)
        .frame(width: 720, height: 400)
}
