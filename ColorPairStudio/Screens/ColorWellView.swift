//
//  ColorWellView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/27/25.
//

import Foundation
import SwiftUI
import AppKit

struct ColorWellView: NSViewRepresentable {
    @Binding var rgba: RGBA

    func makeNSView(context: Context) -> NSColorWell {
        let well = NSColorWell()
        well.isBordered = true
        well.color = NSColor(srgbRed: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
        well.target = context.coordinator
        well.action = #selector(Coordinator.changed(_:))
        return well
    }

    func updateNSView(_ view: NSColorWell, context: Context) {
        view.color = NSColor(srgbRed: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    final class Coordinator: NSObject {
        var parent: ColorWellView
        init(_ parent: ColorWellView) { self.parent = parent }
        @objc func changed(_ sender: NSColorWell) {
            let c = (sender.color.usingColorSpace(.deviceRGB) ?? sender.color)
            parent.rgba = RGBA(r: Double(c.redComponent),
                               g: Double(c.greenComponent),
                               b: Double(c.blueComponent),
                               a: Double(c.alphaComponent))
        }
    }
}
