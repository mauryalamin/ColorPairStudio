//
//  Clipboard.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 10/2/25.
//

import Foundation
import AppKit

enum Clipboard {
    static func copy(_ string: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(string, forType: .string)
    }
}
