//
//  TwinPreview.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import ColorPairCore
import SwiftUI
import AppKit

struct TwinPreview: View {
    let title: String
    let rgba: RGBA
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline).foregroundStyle(.secondary)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: rgba.r, green: rgba.g, blue: rgba.b))
                .frame(height: 120)
                // HEX pill (anchored)
                .overlay(
                    Text(rgba.hexString)
                        .font(.caption.monospaced())
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(.regularMaterial, in: Capsule())
                        .padding(8)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true),
                    alignment: .bottomTrailing
                )
                // Center “Sample” label
                .overlay(
                    Text("Sample")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(radius: 1)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    ClipboardService().copyHex(rgba)   // copy the hex to clipboard
                    onTap?()                           // any UI feedback (toast, etc.)
                }
                .help("Click to copy \(rgba.hexString)")
                .onHover { inside in
                    if inside { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Copies \(rgba.hexString) to the clipboard.")
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
