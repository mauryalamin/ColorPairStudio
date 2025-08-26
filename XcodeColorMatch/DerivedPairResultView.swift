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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Target \(pair.target.hexString)")
                Label(pair.wcagPass ? "WCAG: PASS" : "WCAG: FAIL", systemImage: pair.wcagPass ? "checkmark.seal" : "xmark.seal")
                    .foregroundStyle(pair.wcagPass ? .green : .red)
                Spacer()
                Button("Export to Assets + SwiftUI") { showSheet = true }
            }
            HStack(spacing: 16) {
                TwinPreview(title: "Light", rgba: pair.light)
                TwinPreview(title: "Dark", rgba: pair.dark)
            }
        }
        .sheet(isPresented: $showSheet) {
            ExportSheet(snippet: export())
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
