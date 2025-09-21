//
//  AppearanceToggle.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/29/25.
//

import Foundation
import AppKit

@MainActor
func togglePreviewAppearance() {
    // Look at the *effective* appearance so first toggle works
    let current = NSApp.keyWindow?.effectiveAppearance
        ?? NSApp.mainWindow?.effectiveAppearance
        ?? NSApp.effectiveAppearance

    let isDark = current.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    NSApp.appearance = NSAppearance(named: isDark ? .aqua : .darkAqua)
}
