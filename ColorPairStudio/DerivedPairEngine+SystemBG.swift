//
//  DerivedPairEngine+SystemBG.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/29/25.
//

import Foundation
import AppKit
import ColorPairCore

@MainActor
extension DerivedPairEngine {
    static func refreshSystemBackgrounds() {
        func resolveBG(_ appearance: NSAppearance.Name) -> RGBA {
            var c = NSColor.windowBackgroundColor
            if let ap = NSAppearance(named: appearance) {
                ap.performAsCurrentDrawingAppearance { c = NSColor.windowBackgroundColor }
            }
            let s = c.usingColorSpace(.sRGB) ?? c
            return RGBA(r: Double(s.redComponent),
                        g: Double(s.greenComponent),
                        b: Double(s.blueComponent),
                        a: 1)
        }

        let resolvedLight = resolveBG(.aqua)
        let resolvedDark  = resolveBG(.darkAqua)

        // Safe main-actor write to shared config (Option A pattern)
        DerivedPairEngine.config = .init(lightBG: resolvedLight, darkBG: resolvedDark)
    }
}
