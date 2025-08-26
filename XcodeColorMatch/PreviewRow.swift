//
//  PreviewRow.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI

struct PreviewRow: View {
    var fill: Color
    var hue: Double
    var sat: Double
    var bri: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

                    // Body text on background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(fill) // 1) give fill a ShapeStyle (Color)
                        .hueRotation(.degrees(hue)) // 2) then modify the shape (a View)
                        .saturation(sat)
                        .brightness(bri)
                        .frame(height: 64)
                        .overlay(
                            Text("Body text on background")
                                .foregroundStyle(.white)
                        )

                    // Filled button
                    HStack {
                        Spacer()
                        Text("Continue")
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule()
                                    .fill(fill)
                                    .hueRotation(.degrees(hue))
                                    .saturation(sat)
                                    .brightness(bri)
                            )
                        Spacer()
                    }

                    // List row with color chip
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.background)
                        .frame(height: 44)
                        .overlay(
                            HStack {
                                Image(systemName: "paintpalette")
                                    .foregroundStyle(.primary)
                                Text("List Row Example")
                                Spacer()
                                Circle()
                                    .fill(fill)
                                    .hueRotation(.degrees(hue))
                                    .saturation(sat)
                                    .brightness(bri)
                                    .frame(width: 16, height: 16)
                            }
                            .padding(.horizontal)
                        )
                }
    }
}

#Preview("PreviewRow — Indigo (Light)") {
    PreviewRow(fill: .indigo, hue: 8, sat: 0.95, bri: 0.04)
        .padding(20)
        .frame(width: 860)
        .preferredColorScheme(.light)
}

#Preview("PreviewRow — Teal (Dark)") {
    PreviewRow(fill: .teal, hue: -6, sat: 1.05, bri: -0.02)
        .padding(20)
        .frame(width: 860)
        .preferredColorScheme(.dark)
}

#Preview("PreviewRow — No Adjustments") {
    PreviewRow(fill: .blue, hue: 0, sat: 1.0, bri: 0.0)
        .padding(20)
        .frame(width: 860)
}
