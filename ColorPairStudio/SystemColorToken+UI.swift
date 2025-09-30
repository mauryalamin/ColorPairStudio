//
//  SystemColorToken+UI.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/29/25.
//

import Foundation
import SwiftUI
import ColorPairCore

public extension SystemColorToken {
    var swiftUIColor: Color {
        switch self {
        case .red: .red
        case .orange: .orange
        case .yellow: .yellow
        case .green: .green
        case .mint: .mint
        case .teal: .teal
        case .cyan: .cyan
        case .blue: .blue
        case .indigo: .indigo
        case .purple: .purple
        case .pink: .pink
        case .brown: .brown
        case .gray: .gray
        case .black: .black
        case .white: .white
        case .clear: .clear
        case .primary: .primary
        case .secondary: .secondary
        }
    }
}
