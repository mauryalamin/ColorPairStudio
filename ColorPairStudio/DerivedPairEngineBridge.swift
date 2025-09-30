//
//  DerivedPairEngineBridge.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/29/25.
//

import Foundation
import SwiftUI
import AppKit
import ColorPairCore

enum DerivedPairEngineBridge {
    /// Resolve system window backgrounds for Light/Dark and feed them to the core engine.
    static func refreshSystemBackgrounds() {
        func resolveBG(_ appearance: NSAppearance.Name) -> RGBA {
            var c = NSColor.windowBackgroundColor
            if let ap = NSAppearance(named: appearance) {
                ap.performAsCurrentDrawingAppearance {
                    c = NSColor.windowBackgroundColor
                }
            }
            let s = c.usingColorSpace(.sRGB) ?? c
            return RGBA(
                r: Double(s.redComponent),
                g: Double(s.greenComponent),
                b: Double(s.blueComponent),
                a: 1
            )
        }

        let resolvedLight = resolveBG(.aqua)
        let resolvedDark  = resolveBG(.darkAqua)

        // ✅ main-actor isolated write to the shared config
        Task { @MainActor in
            DerivedPairEngine.config = .init(lightBG: resolvedLight, darkBG: resolvedDark)
        }
    }
}
