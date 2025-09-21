//
//  AppCommands.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/10/25.
//

import Foundation
import SwiftUI
import AppKit

struct AppCommands: Commands {
    // Comes from ContentView via .focusedSceneValue(\.exportAction)
    @FocusedValue(\.exportAction) var exportAction

    var body: some Commands {
        CommandGroup(after: .saveItem) {
            Button("Export Snippet…") {
                exportAction?()   // safe no-op if nil
            }
            .keyboardShortcut("e", modifiers: [.command])
        }
    }
}
