//
//  MatchMode.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation

// MatchMode.swift
enum MatchMode: String, CaseIterable, Hashable {
    case approximator
    case derivedPair // ← if your project uses `.derivedPair`, keep that name instead

    var label: String {
        switch self {
        case .approximator: return "Approximator"
        case .derivedPair:      return "Derived Pair" // or return "Derived Pair" for `.derivedPair`
        }
    }

    var helpText: String {
        switch self {
        case .approximator:
            return "Start from a system color and nudge hue/sat/brightness. Quick and adaptive; export a SwiftUI snippet."
        case .derivedPair:
            return "Generate reusable light/dark twins as a named asset. Exact brand intent, autocomplete everywhere."
        }
    }
}

