//
//  ModeHelp.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/29/25.
//

import SwiftUI

struct ModeHelp: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }
}

#Preview {
    ModeHelp(text: "Some copy goes here")
}
