//
//  XcodeColorMatchApp.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI
import AppKit

@main
struct ColorMatcherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        Settings {
            PreferencesView()
        }
        .commands {
            CommandMenu("View") {
                Button("Toggle Light/Dark Preview") {
                    togglePreviewAppearance()
                }
                    .keyboardShortcut("l", modifiers: [.command])
            }
        }
    }
}
