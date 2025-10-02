//
//  ClipboardService.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 10/2/25.
//

import Foundation
import AppKit
import ColorPairCore

protocol Pasteboarding {
    func setString(_ s: String)
}

extension NSPasteboard: Pasteboarding {
    func setString(_ s: String) {
        clearContents()
        setString(s, forType: .string)
    }
}

struct ClipboardService {
    let pasteboard: Pasteboarding
    init(pasteboard: Pasteboarding = NSPasteboard.general) {
        self.pasteboard = pasteboard
    }

    func copyHex(_ rgba: RGBA) {
        let hex = rgba.hexString
        pasteboard.setString(hex)
        Analytics.track("copied_hex", ["hex": hex])
    }
}
