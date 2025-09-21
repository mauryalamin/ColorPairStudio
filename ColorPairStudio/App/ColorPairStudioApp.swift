//
//  ColorPairStudioApp.swift
//  ColorPairStudioApp
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI
import AppKit

@main
struct ColorPairStudioApp: App {
    var body: some Scene {
        WindowGroup("Color Pair Studio") {
            ContentView()
        }
        Settings {
            PreferencesView()
        }
        .commands {
            // App menu (under “Color Pair Studio”): add Feedback
            CommandGroup(after: .appInfo) {
                Divider()
                Button("Send Feedback…") {
                    NSWorkspace.shared.open(Links.feedback)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift]) // ⌘⇧F
            }
            
            // Help menu (far right): open Support URL
            CommandGroup(replacing: .help) {
                Button("Color Pair Studio Help") {
                    NSWorkspace.shared.open(Links.support)
                }
                // (Optional) add more help items here later
            }
            
            AppCommands()
        }
    }
}

