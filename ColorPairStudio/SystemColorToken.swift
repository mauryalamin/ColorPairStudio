//
//  SystemColorToken.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/19/25.
//

import Foundation
import SwiftUI
import AppKit

/// Canonical, *dotless* SwiftUI system color token.
/// Use `swiftName` for code (`"red"` → `Color.red`)
/// and `displayName` for UI (`".red"`).
enum SystemColorToken: String, CaseIterable, Codable, Hashable {
    case red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown, gray
    
    var swiftName: String { rawValue }            // "red"
    var displayName: String { ".\(rawValue)" }    // ".red"
    
    // Optional helpers if you ever need actual colors:
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
        }
    }
    var nsColor: NSColor {
        switch self {
        case .red: .systemRed
        case .orange: .systemOrange
        case .yellow: .systemYellow
        case .green: .systemGreen
        case .mint: .systemMint
        case .teal: .systemTeal
        case .cyan: .systemCyan
        case .blue: .systemBlue
        case .indigo: .systemIndigo
        case .purple: .systemPurple
        case .pink: .systemPink
        case .brown: .brown
        case .gray: .systemGray
        }
    }
}

extension SystemColorToken {
    /// Initialize from either "red" or ".red".
    init?(maybeDotted name: String) {
        let clean = name.hasPrefix(".") ? String(name.dropFirst()) : name
        self.init(rawValue: clean)
    }
}
