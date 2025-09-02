//
//  Color+Extensions.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation
import SwiftUI

extension Color {
    init(_ rgba: RGBA) {
        self.init(red: rgba.r, green: rgba.g, blue: rgba.b, opacity: rgba.a)
    }
}
