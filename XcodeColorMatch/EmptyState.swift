//
//  EmptyState.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI

struct EmptyState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No result yet")
                .font(.headline)
            Text("Choose a color, pick a mode, then Generate.")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    EmptyState()
}
