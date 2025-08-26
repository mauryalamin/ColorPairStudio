//
//  DerivedPairEngine.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

enum DerivedPairEngine {
    static func derive(from target: RGBA) -> DerivedPair {
        // Very naive: dark twin a bit lighter; light twin a bit darker
        let light = target.adjust(brightness: -0.08)
        let dark = target.adjust(brightness: 0.10)
        let wcagPass = true // TODO: real contrast checks
        return DerivedPair(target: target, light: light, dark: dark, wcagPass: wcagPass)
    }
}
