//
//  DerivedPair.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation
import SwiftUI

struct DerivedPair {
    let target: RGBA
    let light: RGBA
    let dark: RGBA
    let wcagPass: Bool
}

extension DerivedPair {
    static let sample: DerivedPair = {
        let target = RGBA(r: 76/255, g: 111/255, b: 175/255, a: 1)
        return DerivedPairEngine.derive(from: target)
    }()
}
