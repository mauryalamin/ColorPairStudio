//
//  Mode.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/29/25.
//

import Foundation

enum Mode: String, CaseIterable, Hashable {
    case approximator
    case derived

    var label: String {
        switch self {
        case .approximator: return "Approximator"
        case .derived:      return "Derived Pair"
        }
    }

    var helpText: String {
        switch self {
        case .approximator:
            return "Start from a system color and nudge hue/sat/brightness. Quick and adaptive; export a SwiftUI snippet."
        case .derived:
            return "Generate reusable light/dark twins as a named asset. Exact brand intent, autocomplete everywhere."
        }
    }
}
