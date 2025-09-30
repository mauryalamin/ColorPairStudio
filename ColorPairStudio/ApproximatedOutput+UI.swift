//
//  ApproximatedOutput+UI.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/29/25.
//

import Foundation
import SwiftUI
import ColorPairCore

public extension ApproximatedOutput {
    // Convenience for existing UI call-sites
    var baseColor: Color { base.swiftUIColor }
}
