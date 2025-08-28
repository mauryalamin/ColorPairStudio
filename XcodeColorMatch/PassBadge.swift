//
//  PassBadge.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/28/25.
//

import SwiftUI

struct PassBadge: View {
    let title: String
    let pass: Bool
    var body: some View {
        Label(title, systemImage: pass ? "checkmark.seal" : "xmark.seal")
            .font(.caption)
            .labelStyle(.titleAndIcon)
            .padding(.vertical, 4).padding(.horizontal, 8)
            .background(.thinMaterial, in: Capsule())
            .foregroundStyle(pass ? .green : .red)
    }
}


#Preview {
    PassBadge(title: "Pass", pass: false)
}
