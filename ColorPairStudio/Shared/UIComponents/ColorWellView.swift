//
//  ColorWellView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/27/25.
//

import Foundation
import SwiftUI
import AppKit
import ColorPairCore

struct ColorWellView: NSViewRepresentable {
    @Binding var rgba: RGBA
    var cornerRadius: CGFloat = 8
    var showsAlpha: Bool = true
    
    // NEW
        var innerBorderWidth: CGFloat = 0        // 0 = off
        var innerBorderColor: NSColor = .white

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> RoundedWellView {
        let v = RoundedWellView()
        v.cornerRadius = cornerRadius
        v.showsAlpha = showsAlpha
        v.setColor(NSColor(srgbRed: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a))
        v.onChange = { color in
            let c = color.usingColorSpace(NSColorSpace.sRGB) ??
                    color.usingColorSpace(.deviceRGB) ?? color
            context.coordinator.parent.rgba = RGBA(
                r: Double(c.redComponent),
                g: Double(c.greenComponent),
                b: Double(c.blueComponent),
                a: Double(c.alphaComponent)
            )
        }
        return v
    }

    func updateNSView(_ view: RoundedWellView, context: Context) {
        view.setColor(NSColor(srgbRed: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a))
    }

    final class Coordinator: NSObject {
        var parent: ColorWellView
        init(_ parent: ColorWellView) { self.parent = parent }
    }
}

final class RoundedWellView: NSView {
    var cornerRadius: CGFloat = 8 { didSet { layer?.cornerRadius = cornerRadius } }
    var showsAlpha: Bool = true
    var onChange: ((NSColor) -> Void)?

    private var color: NSColor = .systemBlue { didSet { updateLayerColor() } }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerCurve = .continuous
        layer?.masksToBounds = true
        layer?.cornerRadius = cornerRadius
        updateLayerColor()

        let click = NSClickGestureRecognizer(target: self, action: #selector(openPanel))
        addGestureRecognizer(click)
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    override var wantsUpdateLayer: Bool { true }
    override func updateLayer() { updateLayerColor() }

    func setColor(_ c: NSColor) {
        color = c.usingColorSpace(NSColorSpace.sRGB) ?? c
    }

    private func updateLayerColor() {
        layer?.backgroundColor = (color.usingColorSpace(NSColorSpace.sRGB) ?? color).cgColor
    }

    @objc private func openPanel() {
        let panel = NSColorPanel.shared
        panel.showsAlpha = showsAlpha
        panel.color = color
        panel.setTarget(self)
        panel.setAction(#selector(colorDidChange(_:)))
        panel.makeKeyAndOrderFront(nil)
    }

    @objc private func colorDidChange(_ sender: NSColorPanel) {
        let c = sender.color
        setColor(c)
        onChange?(c)
    }
}
