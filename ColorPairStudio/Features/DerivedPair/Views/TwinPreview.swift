//
//  TwinPreview.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI
import ColorPairCore

struct TwinPreview: View {
    var title: String
    var rgba: RGBA
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(rgba))
                .frame(width: 380, height: 120)
                .overlay(Text("Sample").foregroundStyle(.white))
        }
    }
}

#Preview("TwinPreview — Light Twin") {
    TwinPreview(title: "Light", rgba: DerivedPair.sample.light)
        .padding(20)
        .frame(width: 380, height: 180)
}

#Preview("TwinPreview — Dark Twin") {
    TwinPreview(title: "Dark", rgba: DerivedPair.sample.dark)
        .padding(20)
        .frame(width: 380, height: 180)
}

#Preview("TwinPreview — Side by Side") {
    HStack(spacing: 16) {
        TwinPreview(title: "Light", rgba: DerivedPair.sample.light)
        TwinPreview(title: "Dark",  rgba: DerivedPair.sample.dark)
    }
    .padding(20)
    .frame(height: 200)
}
